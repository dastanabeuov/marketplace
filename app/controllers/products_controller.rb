class ProductsController < ApplicationController
  add_breadcrumb I18n.t(".catalog"), :products_path

  # skip_before_action :set_active_main_menu_item
  before_action :set_product, only: [ :show ]
  before_action :load_filters, only: [ :index ]

  def index
    @cart = session[:cart] || {}
    @products = Product.distinct

    if params[:company_id].present?
      @products = @products.joins(:companies).where(companies: { id: params[:company_id] })
    end

    if params[:category_id].present?
      @products = @products.joins(:categories).where(categories: { id: params[:category_id] })
    end

    @products = @products.search_by_column(params[:query], :name)
    @products = @products.page(params[:page]).per(8)
  end

  def show
    unless @product
      redirect_to catalogs_path and return
    end

    add_breadcrumb "#{I18n.t('.product')}: #{@product.name}"
  end

  private

  def set_product
    @product = Product.find_by_id(params[:id])
  end

  def load_filters
    @companies  = Company.pluck(:id, :name)
    @categories = Category.pluck(:id, :name)
  end
end
