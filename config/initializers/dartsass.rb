# Две сборки стилей: application.css — клиентская часть, admin.css — админка.
Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css",
  "admin.scss" => "admin.css"
}
