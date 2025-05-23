class ContactsController < ApplicationController
  add_breadcrumb I18n.t(".contact"), :contact_path

  # skip_before_action :set_active_main_menu_item
  before_action :set_contact, only: [ :show ]

  def show
    unless @contact
      redirect_to root_path and return
    end
  end

  private

  def set_contact
    @contact ||= Contact.first
  end
end
