class Admin::MainController < Admin::BaseController
  add_breadcrumb I18n.t(".dashboard"), :admin_root_path

  def index
    six_months_ago = 6.months.ago.beginning_of_month
    now = Time.zone.now

    users = User.where(last_sign_in_at: six_months_ago..now)

    @admin_users_by_month = users.group_by { |user| user.last_sign_in_at.beginning_of_month }

    # Чтобы получить все 6 месяцев с 0-значениями
    months = (0..5).map { |i| (now - i.months).beginning_of_month }.reverse

    @admin_users_by_month = months.map do |month|
      [ month, @admin_users_by_month[month]&.count || 0 ]
    end.to_h

    @latest_orders ||= Order.order(created_at: :desc).limit(7)

    @companies ||= Company.order("RANDOM()").limit(6)
  end

  def destroy
    head :not_found
  end

  private

  def set_active_main_menu_item
    @main_menu[:main][:active] = true
  end
end
