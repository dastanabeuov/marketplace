# Be sure to restart your server when you modify this file.

# Content Security Policy, адаптированная под приложение.
# См. https://guides.rubyonrails.org/security.html#content-security-policy-header
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self

    # Шрифты — локальные, https и data: (иконочные шрифты Bootstrap).
    policy.font_src :self, :https, :data

    # Картинки: локальные + Active Storage, https, data:/blob: (превью, инлайн-иконки).
    policy.img_src :self, :https, :data, :blob

    policy.object_src :none

    # Встроенная карта на странице контактов — Google Maps embed.
    policy.frame_src :self, "https://www.google.com", "https://maps.google.com"

    # Скрипты: локальные (importmap) + внешний CDN jspm (chart.js, @kurkle/color).
    # Инлайн-скрипты разрешаются через nonce (см. ниже), а не unsafe-inline.
    policy.script_src :self, "https://ga.jspm.io"

    # Стили: unsafe-inline обязателен — Trix, select2, DataTables и Bootstrap
    # инжектят инлайн-стили, плюс в разметке есть атрибуты style="...".
    policy.style_src :self, :https, :unsafe_inline

    # XHR/fetch (Turbo) и websockets (Solid Cable).
    policy.connect_src :self, :https, :wss

    policy.base_uri :self
    policy.form_action :self
    policy.frame_ancestors :self

    # Куда слать отчёты о нарушениях (при необходимости включить эндпоинт).
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Nonce для importmap и разрешённых инлайн-скриптов.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  # Nonce только для script-src: style-src должен сохранить unsafe-inline,
  # иначе браузер проигнорирует unsafe-inline при наличии nonce.
  config.content_security_policy_nonce_directives = %w[script-src]

  # На время обкатки можно включить режим «только отчёты» — политика не
  # применяется, но нарушения логируются в консоли браузера.
  # config.content_security_policy_report_only = true
end
