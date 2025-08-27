class Admin::OrdersController < Admin::BaseController
  add_breadcrumb I18n.t(".orders"), :admin_orders_path

  before_action :set_order, only: [ :show, :edit, :update, :destroy ]

  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html
      format.json do
        begin
          # Получаем параметры от DataTables
          draw = params[:draw].to_i
          start = params[:start].to_i
          length = params[:length].to_i
          search_value = params[:search][:value] if params[:search].present?

          # Получаем параметры сортировки
          sort_column = params[:sort_column] || "created_at"
          sort_direction = params[:sort_direction] || "desc"

          # Проверка безопасности для сортировки (защита от SQL-инъекций)
          allowed_columns = %w[id created_at updated_at order_status user_id phone_number]
          sort_column = "created_at" unless allowed_columns.include?(sort_column)
          sort_direction = sort_direction.to_s.downcase == "asc" ? "asc" : "desc"

          # Основной запрос с включением связанных данных и сортировкой
          orders = Order.includes(:user).order("#{sort_column} #{sort_direction}")

          # Фильтрация, если есть поисковый запрос
          if search_value.present?
            orders = orders.where("CAST(orders.id AS TEXT) LIKE ?", "%#{search_value}%")
          end

          # Общее количество записей без фильтрации (используем кэширование)
          total_records = Rails.cache.fetch("orders_count", expires_in: 10.minutes) do
            Order.count
          end

          # Общее количество записей после фильтрации
          filtered_records = search_value.present? ? orders.count : total_records

          # Пагинация
          orders = orders.offset(start).limit(length)

          # Формируем данные для ответа
          data = orders.map do |order|
            {
              id: order.id,
              user: order.user&.email,
              phone_number: order.user&.phone_number,
              order_status: order.order_status_name,
              created_at: I18n.l(order.created_at, format: :short),
              actions: render_to_string(partial: "admin/orders/actions", locals: { order: order }, formats: [ :html ])
            }
          end

          # Формируем ответ в формате, ожидаемом DataTables
          render json: {
            draw: draw,
            recordsTotal: total_records,
            recordsFiltered: filtered_records,
            data: data
          }
        rescue => e
          # Логирование ошибки
          Rails.logger.error("DataTables error: #{e.message}\n#{e.backtrace.join("\n")}")

          # Возвращаем ошибку клиенту
          render json: {
            draw: params[:draw].to_i,
            recordsTotal: 0,
            recordsFiltered: 0,
            data: [],
            error: "#{I18n.t('error_load_data')}"
          }, status: :internal_server_error
        end
      end
    end
  end

  def show
    add_breadcrumb "#{@order.id}", admin_order_path(@order)
  end

  def edit
    add_breadcrumb "#{I18n.t(".edit")}: #{@order.id}", edit_admin_order_path(@order)
  end

  def update
    if @order.update(order_params)
      redirect_to admin_order_path(@order), notice: "Заказ успешно обновлен"
    else
      flash.now[:alert] = "Ошибка при обновлении заказа"
      render :edit
    end
  end

  def destroy
    @order.destroy
    redirect_to admin_orders_path, notice: "Заказ удалён"
  end

  private

  def set_active_main_menu_item
    @main_menu[:orders][:active] = true
  end

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:order_status, order_items_attributes: [ :id, :product_id, :quantity, :_destroy ])
  end
end
