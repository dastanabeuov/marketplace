class OrdersController < ApplicationController
  add_breadcrumb I18n.t(".orders"), :orders_path

  before_action :authenticate_user!, only: [ :create, :index, :show ]
  before_action :load_cart, except: [ :show, :index ]
  before_action :find_order, only: [ :show ]

  def create
    # Проверка на пустую корзину
    if @cart.blank? || @cart.empty?
      redirect_to products_path, alert: I18n.t("empty_cart")
      return
    end

    begin
      @order = current_user.orders.build(order_status: 0)
      product_ids = @cart.keys.map(&:to_i).compact

      # Проверка существования продуктов
      products = Product.where(id: product_ids)

      if products.count != product_ids.count
        missing_products = product_ids - products.pluck(:id)
        Rails.logger.warn "Missing products with IDs: #{missing_products}"
        redirect_to products_path, alert: I18n.t("products_not_found")
        return
      end

      # Создание позиций заказа
      products.each do |product|
        quantity = @cart[product.id.to_s].to_i

        # Проверка на корректное количество
        if quantity <= 0
          flash.now[:alert] = I18n.t("invalid_quantity")
          render :new
          return
        end

        @order.order_items.build(product: product, quantity: quantity)
      end

      if @order.save
        session[:cart] = {}
        redirect_to order_path(@order), notice: I18n.t("created_order")
      else
        Rails.logger.error "Order creation failed: #{@order.errors.full_messages}"
        flash.now[:alert] = I18n.t("error_order")
        render :new
      end

    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Product not found: #{e.message}"
      redirect_to products_path, alert: I18n.t("products_not_found")
    rescue StandardError => e
      Rails.logger.error "Unexpected error in order creation: #{e.message}"
      redirect_to products_path, alert: I18n.t("error_order")
    end
  end

  def show
    # Проверка выполняется в before_action :find_order
  end

  def index
    begin
      @orders = current_user.orders
                           .includes(order_items: :product)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(8)
    rescue StandardError => e
      Rails.logger.error "Error loading orders: #{e.message}"
      @orders = current_user.orders.none
      flash.now[:alert] = I18n.t("error_loading_orders")
    end
  end

  private

  def order_params
    params.require(:order).permit(
      order_items_attributes: [ :product_id, :quantity ]
    )
  end

  def load_cart
    session[:cart] ||= {}
    @cart = session[:cart]
  end

  def find_order
    # Проверка аутентификации пользователя
    unless current_user
      redirect_to new_user_session_path, alert: I18n.t("please_sign_in")
      return
    end

    begin
      @order = current_user.orders.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn "Order not found: user_id=#{current_user.id}, order_id=#{params[:id]}"
      redirect_to orders_path, alert: I18n.t("order_not_found")
    rescue StandardError => e
      Rails.logger.error "Error finding order: #{e.message}"
      redirect_to orders_path, alert: I18n.t("error_order")
    end
  end
end
