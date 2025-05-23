class TermsOfUseSitesController < ApplicationController
  add_breadcrumb I18n.t(".terms_of_use_site"), :terms_of_use_site_path

  # skip_before_action :set_active_main_menu_item
  before_action :set_terms_of_use_site, only: [ :show ]

  def show
    unless @terms_of_use_site
      redirect_to root_path and return
    end
  end

  private

  def set_terms_of_use_site
    @terms_of_use_site ||= TermsOfUseSite.first
  end
end
