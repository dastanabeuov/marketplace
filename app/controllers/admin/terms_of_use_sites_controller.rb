class Admin::TermsOfUseSitesController < Admin::BaseController
  add_breadcrumb I18n.t(".terms_of_use_site"), :admin_terms_of_use_site_path

  skip_before_action :set_active_main_menu_item
  before_action :set_terms_of_use_site, only: [ :show, :edit, :update, :destroy ]
  before_action :check_singleton_limit, only: [ :new, :create ]

  load_and_authorize_resource

  def show
    unless @terms_of_use_site
      redirect_to new_admin_terms_of_use_site_path and return
    end

    add_breadcrumb @terms_of_use_site.name, admin_terms_of_use_site_path(@terms_of_use_site)
  end

  def new
    add_breadcrumb I18n.t(".new"), :new_admin_terms_of_use_site_path
    @terms_of_use_site = TermsOfUseSite.new
  end

  def create
    @terms_of_use_site = TermsOfUseSite.new(terms_of_use_site_params)
    if @terms_of_use_site.save
      redirect_to admin_terms_of_use_site_path, notice: I18n.t(".created")
    else
      add_breadcrumb I18n.t(".new"), new_admin_terms_of_use_site_path
      flash.now[:alert] = "#{I18n.t(".not_created")}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "#{I18n.t('.edit')}: #{@terms_of_use_site.name}", edit_admin_terms_of_use_site_path(@terms_of_use_site)
  end

  def update
    if @terms_of_use_site.update(terms_of_use_site_params)
      redirect_to admin_terms_of_use_site_path, notice: I18n.t(".updated")
    else
      add_breadcrumb "#{I18n.t('.edit')}: #{@terms_of_use_site.name}", admin_terms_of_use_site_path(@terms_of_use_site)
      flash.now[:alert] = "#{I18n.t(".not_updated")}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @terms_of_use_site.destroy
      redirect_to new_admin_terms_of_use_site_path, notice: I18n.t(".destroyed")
    else
      redirect_to new_admin_terms_of_use_site_path, alert: I18n.t(".not_destroyed")
    end
  end

  private

  def set_terms_of_use_site
    @terms_of_use_site = TermsOfUseSite.first
  end

  def check_singleton_limit
    if TermsOfUseSite.exists?
      redirect_to admin_terms_of_use_site_path, alert: I18n.t(".check_singleton_limit")
    end
  end

  def terms_of_use_site_params
    params.require(:terms_of_use_site).permit(
      *I18n.available_locales.map { |locale| "description_#{locale}" },
      translations_attributes: [ :id, :locale, :name ]
    )
  end
end
