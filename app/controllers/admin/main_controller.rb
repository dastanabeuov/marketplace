class Admin::MainController < Admin::BaseController
  def index
    @breadcrumbs ||= [
      { name: "<i class='bi bi-house'></i> #{I18n.t('.dashboard')}".html_safe, url: admin_root_path, current: true }
    ]
  end
end
