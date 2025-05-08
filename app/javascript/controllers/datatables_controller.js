import { Controller } from "@hotwired/stimulus"
import "jquery"
import "datatables"
// Импортируем языковые файлы
import ruLanguage from "datatables-i18n-ru"
import enLanguage from "datatables-i18n-en"
import kzLanguage from "datatables-i18n-kz"

// Контроллер DataTables
export default class extends Controller {
  // Определяем цели, к которым будем обращаться
  static targets = ["table"]

  // Опции для DataTables
  static values = {
    options: { type: Object, default: {} },
    language: { type: String, default: "ru" } // Параметр для языка
  }

  // Словарь доступных языков
  languages = {
    ru: ruLanguage,
    en: enLanguage,
    kz: kzLanguage
  }

  connect() {
    // Проверяем, что jQuery и DataTables доступны
    if (typeof $ === 'undefined') {
      console.error("jQuery не найден. DataTables не может быть инициализирована.")
      return
    }

    if (!$.fn.DataTable) {
      console.error("DataTables не найдена. Убедитесь, что библиотека загружена.")
      return
    }

    // Защита от CSRF в Ajax-запросах
    $.ajaxSetup({
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    });

    // Инициализируем таблицу
    this.initializeDataTable()
    
    // Слушаем событие turbo:before-cache для очистки таблицы
    document.addEventListener("turbo:before-cache", () => this.disconnect())
  }

  // Метод для инициализации таблицы с выбором языка
  initializeDataTable() {
    try {
      const language = this.languageValue.toLowerCase()
      const languageData = this.languages[language] || {}
      
      // Получаем опции из значения атрибута
      let options = this.optionsValue;
      
      // Если опции включают serverSide, настраиваем колонки
      if (options.serverSide) {
        options.columns = [
          { 
            data: 'name',
            name: 'name',
            orderable: true
          },
          { 
            data: 'updated_at',
            name: 'updated_at',
            orderable: true
          },
          { 
            data: 'actions', 
            orderable: false, 
            searchable: false 
          }
        ];
        
        // Добавляем настройки для серверной сортировки
        options.order = [[1, 'desc']]; // По умолчанию сортируем по дате обновления (desc)
        
        // Настраиваем обработку ajax-запросов для передачи параметров сортировки
        if (options.ajax) {
          const originalAjax = options.ajax;
          
          options.ajax = (data, callback, settings) => {
            // Если ajax задан как строка, преобразуем её в объект
            let ajaxOptions = typeof originalAjax === 'string' 
              ? { url: originalAjax } 
              : originalAjax;
            
            // Проверяем, если у нас есть данные о сортировке
            if (data.order && data.order.length > 0) {
              const order = data.order[0];
              const columnIndex = order.column;
              const columnName = data.columns[columnIndex].name || data.columns[columnIndex].data;
              const direction = order.dir; // 'asc' или 'desc'
              
              // Добавляем параметры сортировки к запросу
              data.sort_column = columnName;
              data.sort_direction = direction;
            }
            
            // Если ajaxOptions — это объект с url
            if (ajaxOptions.url) {
              // Выполняем запрос с нашими параметрами
              $.ajax({
                url: ajaxOptions.url,
                data: data,
                dataType: 'json',
                method: 'GET',
                success: callback,
                error: (xhr, error, thrown) => {
                  console.error('DataTables Ajax error:', error, thrown);
                  callback({ data: [] });
                }
              });
            } 
            // Если ajaxOptions — это функция
            else if (typeof ajaxOptions === 'function') {
              ajaxOptions(data, callback, settings);
            }
          };
        }
      }
      
      // Объединяем пользовательские опции с языковыми настройками
      options = {
        ...options,
        language: languageData
      }

      // Инициализируем DataTables с опциями
      this.dataTable = $(this.tableTarget).DataTable(options)
      console.log(`DataTable успешно инициализирована с языком: ${language}`)
    } catch (error) {
      console.error("Ошибка при инициализации DataTable:", error)
      // Пробуем инициализировать без языковых настроек в случае ошибки
      this.dataTable = $(this.tableTarget).DataTable(this.optionsValue)
    }
  }

  disconnect() {
    // Уничтожаем DataTable при удалении контроллера из DOM
    if (this.dataTable) {
      this.dataTable.destroy()
      this.dataTable = null // Дополнительно очищаем ссылку на таблицу
      console.log("DataTable уничтожена")
    }
  }

  // Метод для обновления данных
  refresh() {
    if (this.dataTable) {
      this.dataTable.ajax.reload()
    }
  }
}