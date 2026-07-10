CanonicalRails.setup do |config|
  # Всегда https в canonical (продакшн работает по https).
  config.protocol = "https://"

  # Основной хост сайта — без слэшей и протокола.
  config.host = "relicom-parts.kz"

  # Фиксируем стандартный https-порт, чтобы он всегда отбрасывался
  # из canonical (иначе за прокси может подставиться :80/:443).
  config.port = 443

  # Слэш в конце оставляем только для коллекций (index).
  config.collection_actions = [ :index ]

  # Все параметры отбрасываются, кроме разрешённых. Оставляем page,
  # чтобы страницы пагинации (kaminari) ссылались canonical сами на себя.
  config.allowed_parameters = [ :page ]

  # og:url уже формируется вручную в layout — не дублируем его тут.
  config.opengraph_url = false
end
