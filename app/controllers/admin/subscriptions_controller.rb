class Admin::SubscriptionsController < Admin::BaseController
  add_breadcrumb I18n.t(".subscriptions"), :admin_subscriptions_path
  skip_before_action :authenticate_admin_user!
  before_action :set_subscription, only: [ :destroy ]

  def unsubscribe
    @subscription = Subscription.find_signed!(params[:id], purpose: :unsubscribe)
    @subscription.destroy
    redirect_to root_path, notice: "Вы успешно отписались от уведомлений."
  end

  def index
    respond_to do |format|
      format.html
      format.json do
        draw = params[:draw].to_i
        start = params[:start].to_i
        length = params[:length].to_i
        search_value = params.dig(:search, :value)

        subscriptions = Subscription.all
        subscriptions = subscriptions.where("email LIKE ?", "%#{search_value}%") if search_value.present?

        total_records = Subscription.count
        filtered_records = subscriptions.count

        subscriptions = subscriptions.offset(start).limit(length)

        data = subscriptions.map do |s|
          {
            email: s.email,
            created_at: l(s.created_at, format: :short),
            actions: render_to_string(partial: "admin/subscriptions/actions", locals: { s: s }, formats: [ :html ])
          }
        end

        render json: {
          draw: draw,
          recordsTotal: total_records,
          recordsFiltered: filtered_records,
          data: data
        }
      end
    end
  end

  def create
    @subscription = Subscription.new(subscription_params)
    if @subscription.save
      redirect_back fallback_location: admin_subscriptions_path, notice: I18n.t(".created")
    else
      redirect_back fallback_location: admin_subscriptions_path, alert: @subscription.errors.full_messages.to_sentence
    end
  end

  def destroy
    @subscription.destroy
    respond_to do |format|
      format.html { redirect_to admin_subscriptions_path, notice: I18n.t(".destroyed") }
      format.json { head :no_content }
    end
  end

  private

  def set_subscription
    @subscription = Subscription.find_by_id(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(:email)
  end

  def set_active_main_menu_item
    @main_menu[:subscriptions][:active] = true
  end
end
