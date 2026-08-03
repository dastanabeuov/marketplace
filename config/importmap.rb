# Точки входа: application — клиентская часть сайта, admin — админка.
# preload: "admin" означает, что модуль предзагружается только на страницах админки.
pin "application", preload: "application"
pin "admin",       preload: "admin"

pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

# Общие контроллеры — нужны и на клиенте, и в админке
pin_all_from "app/javascript/controllers", under: "controllers"
# Контроллеры только для админки
pin_all_from "app/javascript/admin_controllers", under: "admin_controllers", preload: "admin"
# Хелперы ленивой загрузки вендорных библиотек
pin_all_from "app/javascript/lib", under: "lib"

pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true

# Тяжёлые библиотеки грузятся динамически из контроллеров (см. lib/load_vendor.js),
# поэтому не предзагружаем их ни на одной точке входа.
pin "datatables", to: "datatables/datatables.js", preload: false
pin "jquery", to: "jquery/jquery-3.7.1.js", preload: false
# pin "cocoon-js", to: "cocoon/cocoon.js"

# Языковые файлы для DataTables
pin "datatables-i18n-ru", to: "datatables/i18n/russian.js", preload: false
pin "datatables-i18n-en", to: "datatables/i18n/english.js", preload: false
pin "datatables-i18n-kz", to: "datatables/i18n/kazakh.js", preload: false

pin "color-modes", to: "color-modes/color-modes.js", preload: true

pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@4.4.4/dist/chart.js", preload: false
pin "@kurkle/color", to: "https://ga.jspm.io/npm:@kurkle/color@0.3.2/dist/color.esm.js", preload: false

pin "select2", to: "select/select2.js", preload: false

# Редактор Trix нужен только в формах админки
pin "trix", preload: "admin"
pin "@rails/actiontext", to: "actiontext.esm.js", preload: "admin"
