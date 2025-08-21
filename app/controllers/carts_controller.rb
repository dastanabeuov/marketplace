class CartsController < ApplicationController
  add_breadcrumb I18n.t(".cart"), :cart_path
  before_action :load_cart

  def show
  end

  def add_item
    product_id = params[:product_id].to_s
    @cart[product_id] ||= 0
    @cart[product_id] += 1
    save_cart

    flash.now[:notice] = "#{I18n.t(".add_cart")}"

    respond_to do |format|
      format.turbo_stream do
        @product = Product.find(product_id)
        @cart = session[:cart] || {}

        render turbo_stream: [
          turbo_stream.replace("cart_button_#{product_id}", partial: "products/cart_button", locals: { product: @product, cart: @cart }),
          turbo_stream.replace("flash_messages", partial: "shared/flash", locals: { flash: flash })
        ]
      end
      format.html { redirect_to cart_path, notice: "#{I18n.t(".add_cart")}" }
    end
  end

  def update_quantity
    product_id = params[:product_id].to_s
    quantity = params[:quantity].to_i.clamp(1, 999)

    session[:cart][product_id] = quantity
    @cart = session[:cart]
    @product = Product.find_by(id: product_id)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "cart_item_#{product_id}",
          partial: "carts/cart_item",
          locals: { product: @product, quantity: quantity }
        )
      end
      format.html { redirect_to cart_path }
    end
  end

  def remove_item
    product_id = params[:product_id].to_s
    session[:cart]&.delete(product_id)

    respond_to do |format|
      format.turbo_stream do
        @cart = session[:cart] || {}
        render turbo_stream: turbo_stream.replace("cart_contents", partial: "cart_contents", locals: { cart: @cart }), layout: false
      end
      format.html { redirect_to cart_path, notice: "#{I18n.t(".destroy_cart")}Товар удален из корзины" }
    end
  end

  def clear
    session[:cart] = {}
    @cart = {}

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path, notice: "#{I18n.t(".removed_cart")}" }
    end
  end

  private

  def load_cart
    session[:cart] ||= {}
    @cart = session[:cart]
  end

  def save_cart
    session[:cart] = @cart.presence || {}
  end
end
