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
    language: { type: String, default: "ru" }, // Параметр для языка
    columns: { type: Array, default: [] } // Добавляем параметр для колонок
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
        // Используем переданные колонки или определяем по умолчанию
        options.columns = this.columnsValue.length > 0 ? this.columnsValue : this.getDefaultColumns();
        
        // Добавляем настройки для серверной сортировки
        options.order = this.getDefaultOrder();
        
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

  // Определяем колонки по умолчанию на основе заголовков таблицы
  getDefaultColumns() {
    const tableType = this.getTableType();
    
    switch (tableType) {
      case 'orders':
        return [
          { data: 'id', name: 'id', orderable: true },
          { data: 'user', name: 'user', orderable: true },
          { data: 'phone_number', name: 'phone_number', orderable: true },
          { data: 'order_status', name: 'order_status', orderable: true },
          { data: 'created_at', name: 'created_at', orderable: true },
          { data: 'actions', orderable: false, searchable: false }
        ];
      case 'companies':
      default:
        return [
          { data: 'name', name: 'name', orderable: true },
          { data: 'updated_at', name: 'updated_at', orderable: true },
          { data: 'actions', orderable: false, searchable: false }
        ];
    }
  }

  // Определяем тип таблицы по URL или контексту
  getTableType() {
    const url = window.location.pathname;
    if (url.includes('/orders')) {
      return 'orders';
    } else if (url.includes('/companies')) {
      return 'companies';
    }
    return 'default';
  }

  // Определяем сортировку по умолчанию
  getDefaultOrder() {
    const tableType = this.getTableType();
    
    switch (tableType) {
      case 'orders':
        return [[4, 'desc']]; // Сортируем по created_at (5-я колонка, индекс 4)
      case 'companies':
      default:
        return [[1, 'desc']]; // Сортируем по updated_at (2-я колонка, индекс 1)
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