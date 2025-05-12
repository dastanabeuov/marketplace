class Admin::AboutsController < Admin::BaseController
  add_breadcrumb I18n.t(".about"), :admin_about_path

  skip_before_action :set_active_main_menu_item
  before_action :set_about, only: [ :show, :edit, :update, :destroy ]
  before_action :check_singleton_limit, only: [ :new, :create ]

  load_and_authorize_resource

  def show
    unless @about
      redirect_to new_admin_about_path and return
    end

    add_breadcrumb @about.name, admin_about_path(@about)
  end

  def new
    add_breadcrumb I18n.t(".new"), :new_admin_about_path
    @about = About.new
  end

  def create
    @about = About.new(sitename_params)
    if @about.save
      redirect_to admin_about_path, notice: I18n.t(".created")
    else
      add_breadcrumb I18n.t(".new"), new_admin_about_path
      flash.now[:alert] = "#{I18n.t(".not_created")}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "#{I18n.t('.edit')}: #{@about.name}", edit_admin_about_path(@about)
  end

  def update
    if @about.update(sitename_params)
      redirect_to admin_about_path, notice: I18n.t(".updated")
    else
      add_breadcrumb "#{I18n.t('.edit')}: #{@about.name}", admin_about_path(@about)
      flash.now[:alert] = "#{I18n.t(".not_updated")}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @about.destroy
      redirect_to new_admin_about_path, notice: I18n.t(".destroyed")
    else
      redirect_to new_admin_about_path, alert: I18n.t(".not_destroyed")
    end
  end

  private

  def set_about
    @about = About.first
  end

  def check_singleton_limit
    if About.exists?
      redirect_to admin_about_path, alert: I18n.t(".check_singleton_limit")
    end
  end

  def sitename_params
    params.require(:about).permit(:name, :description)
  end
end
