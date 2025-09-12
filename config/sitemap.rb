# config/sitemap.rb
SitemapGenerator::Sitemap.default_host = "https://relicom-parts.kz"

SitemapGenerator::Sitemap.create do
  helpers = Rails.application.routes.url_helpers
  default_options = { host: SitemapGenerator::Sitemap.default_host }

  # Статические страницы
  add helpers.root_url(default_options),        priority: 1.0, changefreq: "daily"
  add helpers.about_url(default_options),       priority: 0.6, changefreq: "monthly"
  add helpers.contact_url(default_options),     priority: 0.6, changefreq: "monthly"
  add helpers.privacy_policy_url(default_options), priority: 0.3, changefreq: "yearly"
  add helpers.terms_of_use_site_url(default_options), priority: 0.3, changefreq: "yearly"
  add helpers.cart_url(default_options),        priority: 0.5, changefreq: "weekly"

  # Компании
  Company.find_each do |company|
    add helpers.company_url(company, default_options), lastmod: company.updated_at

    company.products.find_each do |product|
      add helpers.product_company_url(company, product_id: product.id, **default_options),
          lastmod: product.updated_at
    end
  end

  # Продукты
  Product.find_each do |product|
    add helpers.product_url(product, default_options), lastmod: product.updated_at
  end

  # Механики
  Mechanic.find_each do |mechanic|
    add helpers.mechanic_url(mechanic, default_options), lastmod: mechanic.updated_at
  end

  # Вакансии
  Vacancy.find_each do |vacancy|
    add helpers.vacancy_url(vacancy, default_options), lastmod: vacancy.updated_at
  end
end
