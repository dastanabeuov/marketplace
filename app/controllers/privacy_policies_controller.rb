class PrivacyPoliciesController < ApplicationController
  add_breadcrumb I18n.t(".privacy_policy"), :privacy_policy_path

  # skip_before_action :set_active_main_menu_item
  before_action :set_privacy_policy, only: [ :show ]

  def show
    unless @privacy_policy
      redirect_to root_path and return
    end
  end

  private

  def set_privacy_policy
    @privacy_policy ||= PrivacyPolicy.first
  end
end
