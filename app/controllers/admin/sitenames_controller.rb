class Admin::SitenamesController < Admin::BaseController
  include AttachableImageRemoval

  add_breadcrumb I18n.t(".sitename"), :admin_sitename_path

  skip_before_action :set_active_main_menu_item
  before_action :set_sitename, only: [ :show, :edit, :update, :destroy ]
  before_action :check_singleton_limit, only: [ :new, :create ]

  load_and_authorize_resource

  def show
    unless @sitename
      redirect_to new_admin_sitename_path and return
    end

    add_breadcrumb @sitename.name, admin_sitename_path(@sitename)
  end

  def new
    add_breadcrumb I18n.t(".new"), :new_admin_sitename_path
    @sitename = Sitename.new
  end

  def create
    @sitename = Sitename.new(sitename_params)
    if @sitename.save
      redirect_to admin_sitename_path, notice: I18n.t(".created")
    else
      add_breadcrumb I18n.t(".new"), new_admin_sitename_path
      flash.now[:alert] = "#{I18n.t(".not_created")}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "#{I18n.t('.edit')}: #{@sitename.name}", edit_admin_sitename_path(@sitename)
  end

  def update
    if @sitename.update(sitename_params)
      redirect_to admin_sitename_path, notice: I18n.t(".updated")
    else
      add_breadcrumb "#{I18n.t('.edit')}: #{@sitename.name}", admin_sitename_path(@sitename)
      flash.now[:alert] = "#{I18n.t(".not_updated")}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @sitename.destroy
      redirect_to new_admin_sitename_path, notice: I18n.t(".destroyed")
    else
      redirect_to new_admin_sitename_path, alert: I18n.t(".not_destroyed")
    end
  end

  private

  def set_sitename
    @sitename = Sitename.first
  end

  def check_singleton_limit
    if Sitename.exists?
      redirect_to admin_sitename_path, alert: I18n.t(".check_singleton_limit")
    end
  end

  def sitename_params
    params.require(:sitename).permit(:image, :name, :description)
  end
end
