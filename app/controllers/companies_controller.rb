class CompaniesController < ApplicationController
  add_breadcrumb I18n.t(".companies"), :companies_path

  before_action :load_filters, only: [ :index ]
  before_action :set_company, only: [ :show, :product ]

  def index
    @companies = Company.distinct

    # Фильтр по компании
    if params[:company_id].present?
      @companies = @companies.where(id: params[:company_id])
    end

    # Поиск по названию (кросс-БД)
    @companies = @companies.search_by_column(params[:query], :name)

    @companies = @companies.page(params[:page]).per(8)
  end

  def show
    unless @company
      redirect_to companies_path and return
    end

    @products = @company.products.page(params[:page]).per(8) if @company

    add_breadcrumb @company.name, "#"
  end

  def product
    unless @company
      redirect_to companies_path and return
    end

    @product = @company.products.find_by_id(params[:product_id])

    unless @product
      redirect_to company_path(@company) and return
    end

    add_breadcrumb @company.name, company_path(@company)
    add_breadcrumb @product.name, "#"
  end

  def site_name
    Rails.cache.fetch("site_name", expires_in: 1.day) do
      Sitename.first&.name || "Default-Site-Name"
    end
  end

  private

  def set_company
    @company = Company.find_by_id(params[:id])
  end

  def load_filters
    @company_filters  = Company.pluck(:id, :name)
  end
end
