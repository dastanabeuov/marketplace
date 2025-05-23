class AboutsController < ApplicationController
  add_breadcrumb I18n.t(".about"), :about_path

  # skip_before_action :set_active_main_menu_item
  before_action :set_about, only: [ :show ]

  def show
    unless @about
      redirect_to root_path and return
    end
  end

  private

  def set_about
    @about ||= About.first
  end
end
