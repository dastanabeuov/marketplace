import { Controller } from "@hotwired/stimulus"
import { loadSelect2 } from "lib/load_vendor"

export default class extends Controller {
  static targets = ["field"]
  static values = {
    placeholder: String,
    allowClear: Boolean,
    multiple: Boolean,
    tags: Boolean,
    minimumInputLength: Number,
    maximumSelectionLength: Number,
    closeOnSelect: Boolean,
    dropdownParent: String,
    ajaxUrl: String,
    pageSize: { type: Number, default: 10 },
    // Значения для локализации
    noResults: String,
    searching: String,
    loadingMore: String,
    inputTooShort: String,
    selectionTooLong: String,
    language: { type: String, default: 'en' }
  }

  async connect() {
    // jQuery и Select2 грузим только на страницах с такими полями
    try {
      await loadSelect2()
    } catch (error) {
      console.error("Не удалось загрузить Select2:", error)
      return
    }

    if (!this.element.isConnected) return

    this.initialized = true
    this.initializeSelect2()
    console.log('✅ Select2 initialized')
  }

  disconnect() {
    if (!this.initialized) return

    this.destroySelect2()
    console.log('🛑 Select2 destroyed')
  }

  initializeSelect2() {
    if (!$.fn.select2) {
      console.error("Select2 is not loaded!")
      return
    }

    this.fieldTargets.forEach(field => {
      const options = this.buildOptions()
      
      $(field).select2(options)
        .on('select2:open', () => {
          document.querySelector('.select2-search__field')?.focus()
        })
    })
  }

  destroySelect2() {
    this.fieldTargets.forEach(field => {
      try {
        $(field).select2('destroy')
      } catch (e) {
        console.warn("Error destroying Select2", e)
      }
    })
  }

  buildOptions() {
    const options = {
      width: '100%',
      pageSize: this.pageSizeValue,
      templateResult: this.formatResult,
      templateSelection: this.formatSelection,
      createTag: this.createTag,
      // Активируем встроенную подсветку выбранных элементов
      // Это встроенный функционал Select2
      escapeMarkup: function(markup) {
        return markup;
      }
    }

    if (this.hasPlaceholderValue) {
      options.placeholder = this.placeholderValue
    }

    if (this.hasAllowClearValue) {
      options.allowClear = this.allowClearValue
    }

    if (this.hasMultipleValue) {
      options.multiple = this.multipleValue
    }

    if (this.hasTagsValue) {
      options.tags = this.tagsValue
    }

    if (this.hasMinimumInputLengthValue) {
      options.minimumInputLength = this.minimumInputLengthValue
    }

    if (this.hasMaximumSelectionLengthValue) {
      options.maximumSelectionLength = this.maximumSelectionLengthValue
    }

    if (this.hasCloseOnSelectValue) {
      options.closeOnSelect = this.closeOnSelectValue
    }

    if (this.hasDropdownParentValue) {
      options.dropdownParent = $(this.dropdownParentValue)
    }

    if (this.hasAjaxUrlValue) {
      options.ajax = this.buildAjaxOptions()
    }

    // Добавляем локализацию
    options.language = this.buildLanguageOptions()

    return options
  }

  buildLanguageOptions() {
    const language = {}

    if (this.hasNoResultsValue) {
      language.noResults = () => this.noResultsValue
    }

    if (this.hasSearchingValue) {
      language.searching = () => this.searchingValue
    }

    if (this.hasLoadingMoreValue) {
      language.loadingMore = () => this.loadingMoreValue
    }

    if (this.hasInputTooShortValue) {
      language.inputTooShort = (args) => {
        const remainingChars = args.minimum - args.input.length
        return this.inputTooShortValue.replace('%{count}', remainingChars)
      }
    }

    if (this.hasSelectionTooLongValue) {
      language.maximumSelected = (args) => {
        return this.selectionTooLongValue.replace('%{count}', args.maximum)
      }
    }

    return language
  }

  buildAjaxOptions() {
    return {
      url: this.ajaxUrlValue,
      dataType: 'json',
      delay: 250,
      data: (params) => ({
        term: params.term || '',
        page: params.page || 1,
        per_page: this.pageSizeValue
      }),
      processResults: (data, params) => {
        params.page = params.page || 1
        return {
          results: data.results,
          pagination: { more: data.pagination.more }
        }
      },
      cache: true
    }
  }

  refresh() {
    this.fieldTargets.forEach(field => {
      $(field).trigger('change')
    })
  }

  createTag(params) {
    return {
      id: 'new:' + params.term,
      text: params.term,
      newTag: true
    }
  }

  formatResult(item) {
    if (item.loading) return item.text
    
    // Используем встроенный механизм Select2 для определения выбранных элементов
    const $result = $(
      '<div class="select2-result-item">' +
        '<div class="select2-result-item__name">' + item.text + '</div>' +
      '</div>'
    )
    
    // Select2 автоматически добавит класс .select2-results__option--selected
    // к элементу списка, который уже выбран
    
    return $result
  }

  formatSelection(item) {
    return item.text
  }
}