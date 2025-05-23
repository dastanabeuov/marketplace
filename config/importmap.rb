pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/resources", under: "resources"

pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true

pin "datatables", to: "datatables/datatables.js"
pin "jquery", to: "jquery/jquery-3.7.1.js"

# Языковые файлы для DataTables
pin "datatables-i18n-ru", to: "datatables/i18n/russian.js"
pin "datatables-i18n-en", to: "datatables/i18n/english.js"
pin "datatables-i18n-kz", to: "datatables/i18n/kazakh.js"

pin "color-modes", to: "color-modes/color-modes.js", preload: true

pin "chart.js", to: "https://ga.jspm.io/npm:chart.js@4.4.4/dist/chart.js"
pin "@kurkle/color", to: "https://ga.jspm.io/npm:@kurkle/color@0.3.2/dist/color.esm.js"

pin "select2", to: "select/select2.js"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
