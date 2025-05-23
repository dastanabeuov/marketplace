class Admin::ContactsController < Admin::BaseController
  include AttachableImageRemoval

  add_breadcrumb I18n.t(".contact"), :admin_contact_path

  skip_before_action :set_active_main_menu_item
  before_action :set_contact, only: [ :show, :edit, :update, :destroy ]
  before_action :check_singleton_limit, only: [ :new, :create ]

  def show
    unless @contact
      redirect_to new_admin_contact_path and return
    end

    add_breadcrumb @contact.name, admin_contact_path(@contact)
  end

  def new
    add_breadcrumb I18n.t(".new"), :new_admin_contact_path
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to admin_contact_path, notice: I18n.t(".created")
    else
      add_breadcrumb I18n.t(".new"), new_admin_contact_path
      flash.now[:alert] = "#{I18n.t(".not_created")}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "#{I18n.t('.edit')}: #{@contact.name}", edit_admin_contact_path(@contact)
  end

  def update
    if @contact.update(contact_params)
      redirect_to admin_contact_path, notice: I18n.t(".updated")
    else
      add_breadcrumb "#{I18n.t('.edit')}: #{@contact.name}", admin_contact_path(@contact)
      flash.now[:alert] = "#{I18n.t(".not_updated")}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @contact.destroy
      redirect_to new_admin_contact_path, notice: I18n.t(".destroyed")
    else
      redirect_to new_admin_contact_path, alert: I18n.t(".not_destroyed")
    end
  end

  private

  def set_contact
    @contact = Contact.first
  end

  def check_singleton_limit
    if Contact.exists?
      redirect_to admin_contact_path, alert: I18n.t(".check_singleton_limit")
    end
  end

  def contact_params
    params.require(:contact).permit(:image, :name, :working_hours, :email, :phone, :address, :map_iframe)
  end
end
