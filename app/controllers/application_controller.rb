class ApplicationController < ActionController::Base
  include Localization

  # before_action :authenticate_user!

  include ErrorHandling

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_url, alert: exception.message }
      format.js { head :forbiddens }
      format.json { head :forbidden }
    end
  end

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
