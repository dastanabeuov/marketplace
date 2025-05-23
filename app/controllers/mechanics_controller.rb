class MechanicsController < ApplicationController
  add_breadcrumb I18n.t(".mechanic"), :mechanic_path

  before_action :set_mechanic, only: [ :show ]

  def show
    unless @mechanic
      redirect_to root_path and return
    end

    add_breadcrumb @mechanic.name, mechanic_path(@mechanic)
  end

  private

  def set_mechanic
    @mechanic = Mechanic.find_by_id(params[:id])
  end
end
