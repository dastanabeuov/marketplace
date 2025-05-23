class Admin::PrivacyPoliciesController < Admin::BaseController
  add_breadcrumb I18n.t(".privacy_policy"), :admin_privacy_policy_path

  skip_before_action :set_active_main_menu_item
  before_action :set_privacy_policy, only: [ :show, :edit, :update, :destroy ]
  before_action :check_singleton_limit, only: [ :new, :create ]

  def show
    unless @privacy_policy
      redirect_to new_admin_privacy_policy_path and return
    end

    add_breadcrumb @privacy_policy.name, admin_privacy_policy_path(@privacy_policy)
  end

  def new
    add_breadcrumb I18n.t(".new"), :new_admin_privacy_policy_path
    @privacy_policy = PrivacyPolicy.new
  end

  def create
    @privacy_policy = PrivacyPolicy.new(privacy_policy_params)
    if @privacy_policy.save
      redirect_to admin_privacy_policy_path, notice: I18n.t(".created")
    else
      add_breadcrumb I18n.t(".new"), new_admin_privacy_policy_path
      flash.now[:alert] = "#{I18n.t(".not_created")}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "#{I18n.t('.edit')}: #{@privacy_policy.name}", edit_admin_privacy_policy_path(@privacy_policy)
  end

  def update
    if @privacy_policy.update(privacy_policy_params)
      redirect_to admin_privacy_policy_path, notice: I18n.t(".updated")
    else
      add_breadcrumb "#{I18n.t('.edit')}: #{@privacy_policy.name}", admin_privacy_policy_path(@privacy_policy)
      flash.now[:alert] = "#{I18n.t(".not_updated")}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @privacy_policy.destroy
      redirect_to new_admin_privacy_policy_path, notice: I18n.t(".destroyed")
    else
      redirect_to new_admin_privacy_policy_path, alert: I18n.t(".not_destroyed")
    end
  end

  private

  def set_privacy_policy
    @privacy_policy = PrivacyPolicy.first
  end

  def check_singleton_limit
    if PrivacyPolicy.exists?
      redirect_to admin_privacy_policy_path, alert: I18n.t(".check_singleton_limit")
    end
  end

  def privacy_policy_params
    params.require(:privacy_policy).permit(:name, :description)
  end
end
