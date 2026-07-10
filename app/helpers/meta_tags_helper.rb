module MetaTagsHelper
  # Устанавливает мета-теги страницы из вьюхи одним вызовом.
  def set_meta_tags(title:, description: nil, image: nil, url: nil, type: "website")
    content_for :title, title
    content_for :description, description if description.present?
    content_for :og_title, title
    content_for :og_description, description if description.present?
    content_for :og_image, image if image.present?
    content_for :og_url, url || request.original_url
    content_for :og_type, type
  end

  # Итоговый <title>: "<заголовок страницы> | <название сайта>".
  # Если страница не задала свой заголовок — берётся общий по умолчанию.
  def meta_title
    page = content_for?(:title) ? content_for(:title) : default_meta_title
    [ page.presence, site_name.presence ].compact.uniq.join(" | ")
  end

  # Итоговое описание страницы: то, что задала страница
  # (content_for :description или og_description), иначе — общий fallback.
  def meta_description
    description =
      (content_for(:description) if content_for?(:description)) ||
      (content_for(:og_description) if content_for?(:og_description))

    (description.presence || default_meta_description).to_s.squish
  end

  def default_meta_title
    I18n.t("meta.default_title", default: I18n.t("home_index_h1_title"))
  end

  def default_meta_description
    # site_description может быть ActionText (rich text) — приводим к плоскому тексту,
    # иначе в meta попадёт HTML-разметка.
    site = site_description
    site = site.to_plain_text if site.respond_to?(:to_plain_text)
    strip_tags(site.to_s).squish.presence || I18n.t("meta.default_description")
  end
end
