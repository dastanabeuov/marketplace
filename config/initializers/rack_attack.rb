# frozen_string_literal: true

# Конфигурация rack-attack: троттлинг, блокировки и fail2ban.
# Middleware подключается автоматически через Railtie гема, счётчики
# хранятся в Rails.cache (в production — Solid Cache).
class Rack::Attack
  # В тестах троттлинг только мешает.
  Rack::Attack.enabled = false if Rails.env.test?

  # Статику и файлы Active Storage в лимитах не учитываем.
  ASSET_PATHS = %w[/assets /rails/active_storage].freeze

  ### Белый список ###

  # Локальные запросы и health-check не ограничиваем.
  safelist("allow/localhost") do |req|
    [ "127.0.0.1", "::1" ].include?(req.ip)
  end

  safelist("allow/health-check") do |req|
    req.path == "/up"
  end

  ### Общий троттлинг по IP ###

  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless ASSET_PATHS.any? { |p| req.path.start_with?(p) }
  end

  ### Троттлинг входа (защита от brute-force) ###

  # По IP: не больше 10 попыток входа за 20 секунд
  # (покрывает /users/sign_in и /admin/admin_users/sign_in).
  throttle("logins/ip", limit: 10, period: 20.seconds) do |req|
    req.ip if req.post? && req.path.end_with?("/sign_in")
  end

  # По email: не больше 10 попыток на один email за минуту.
  throttle("logins/email", limit: 10, period: 1.minute) do |req|
    if req.post? && req.path.end_with?("/sign_in")
      email = begin
        req.params.dig("user", "email") || req.params.dig("admin_user", "email")
      rescue StandardError
        nil
      end
      email.to_s.downcase.strip.presence
    end
  end

  ### Троттлинг регистраций ###

  throttle("signups/ip", limit: 5, period: 1.minute) do |req|
    req.ip if req.post? && req.path == "/users"
  end

  ### Троттлинг отправки форм (заказы, корзина, подписка) ###

  POST_ENDPOINTS = %w[/orders /cart /admin/subscriptions].freeze
  throttle("posts/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.post? && POST_ENDPOINTS.any? { |p| req.path.start_with?(p) }
  end

  ### fail2ban: бан сканеров уязвимостей ###

  # 3 обращения к «подозрительным» путям за 10 минут → бан IP на час.
  blocklist("fail2ban/scanners") do |req|
    Rack::Attack::Fail2Ban.filter("scanners/#{req.ip}", maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
      path = req.path.downcase
      CGI.unescape(req.query_string.to_s).include?("/etc/passwd") ||
        path.include?("/etc/passwd") ||
        path.match?(/\.(php|asp|aspx|env|git|sql|bak)$/) ||
        path.match?(/wp-(login|admin)|xmlrpc/)
    end
  end

  ### Ответ при превышении лимита ###

  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"] || {}
    retry_after = (match_data[:period] || 60).to_i
    [
      429,
      { "Content-Type" => "text/plain; charset=utf-8", "Retry-After" => retry_after.to_s },
      [ "Слишком много запросов. Повторите попытку позже.\n" ]
    ]
  end
end

# Логируем срабатывания троттлинга и блокировок.
ActiveSupport::Notifications.subscribe("rack.attack") do |_name, _start, _finish, _id, payload|
  req = payload[:request]
  next unless [ :throttle, :blocklist ].include?(req.env["rack.attack.match_type"])

  Rails.logger.warn(
    "[Rack::Attack] #{req.env['rack.attack.match_type']} " \
    "rule=#{req.env['rack.attack.matched']} ip=#{req.ip} " \
    "#{req.request_method} #{req.fullpath}"
  )
end
