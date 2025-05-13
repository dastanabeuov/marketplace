class Admin::ProductsController < Admin::BaseController
  add_breadcrumb I18n.t(".products"), :admin_products_path

  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  load_and_authorize_resource except: [ :search_company, :search_category ]

  def search_category
    term = params[:term].to_s.strip
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i

    # Логируем параметры запроса
    Rails.logger.info("Search params: term=#{term}, page=#{page}, per_page=#{per_page}")

    # Исключим уже выбранные компании, если они переданы
    excluded_ids = params[:excluded_ids].present? ? params[:excluded_ids].map(&:to_i) : []

    query = Category.where("name ILIKE ?", "%#{term}%")
    query = query.where.not(id: excluded_ids) if excluded_ids.any?

    # Считаем общее количество
    total_count = query.count
    Rails.logger.info("Total matching categories: #{total_count}")

    categories = query
                .order(:name)
                .offset((page - 1) * per_page)
                .limit(per_page + 1)

    more = categories.size > per_page
    categories = categories.first(per_page)

    results = categories.map { |c| { id: c.id, text: c.name } }
    Rails.logger.info("Returning #{results.size} categories, more: #{more}")

    render json: {
      results: results,
      pagination: { more: more }
    }
  end

  def search_company
    term = params[:term].to_s.strip
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i

    # Логируем параметры запроса
    Rails.logger.info("Search params: term=#{term}, page=#{page}, per_page=#{per_page}")

    # Исключим уже выбранные компании, если они переданы
    excluded_ids = params[:excluded_ids].present? ? params[:excluded_ids].map(&:to_i) : []

    query = Company.where("name ILIKE ?", "%#{term}%")
    query = query.where.not(id: excluded_ids) if excluded_ids.any?

    # Считаем общее количество
    total_count = query.count
    Rails.logger.info("Total matching companies: #{total_count}")

    companies = query
                .order(:name)
                .offset((page - 1) * per_page)
                .limit(per_page + 1)

    more = companies.size > per_page
    companies = companies.first(per_page)

    results = companies.map { |c| { id: c.id, text: c.name } }
    Rails.logger.info("Returning #{results.size} companies, more: #{more}")

    render json: {
      results: results,
      pagination: { more: more }
    }
  end

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
          sort_column = params[:sort_column] || "updated_at"
          sort_direction = params[:sort_direction] || "desc"

          # Проверка безопасности для сортировки (защита от SQL-инъекций)
          allowed_columns = %w[name updated_at created_at price]
          sort_column = "updated_at" unless allowed_columns.include?(sort_column)
          sort_direction = sort_direction.to_s.downcase == "asc" ? "asc" : "desc"

          # Основной запрос с сортировкой
          products = Product.order("#{sort_column} #{sort_direction}")

          # Фильтрация, если есть поисковый запрос
          if search_value.present?
            products = products.where("name LIKE ?", "%#{search_value}%")
          end

          # Общее количество записей без фильтрации
          total_records = Rails.cache.fetch("products_count", expires_in: 10.minutes) do
            Product.count
          end

          # Общее количество записей после фильтрации
          filtered_records = search_value.present? ? products.count : total_records

          # Пагинация
          products = products.offset(start).limit(length)

          # Формируем данные для ответа
          data = products.map do |product|
            {
              name: product.name,
              updated_at: I18n.l(product.updated_at, format: :long),
              actions: render_to_string(partial: "admin/products/actions", locals: { product: product }, formats: [ :html ])
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
            error: "Произошла ошибка при загрузке данных"
          }, status: :internal_server_error
        end
      end
    end
  end

  def show
    add_breadcrumb @product.name, admin_product_path(@product)
  end

  def new
    add_breadcrumb I18n.t(".new"), new_admin_product_path

    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to admin_product_path(@product), notice: I18n.t(".created")
    else
      add_breadcrumb I18n.t(".new"), new_admin_product_path
      flash.now[:alert] = "#{I18n.t(".not_created")}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "#{I18n.t('.edit')}: #{@product.name}", edit_admin_product_path(@product)
  end

  def update
    if @product.update(product_params)
      redirect_to admin_product_path(@product), notice: I18n.t(".updated")
    else
      add_breadcrumb "#{I18n.t('.edit')}: #{@product.name}", admin_product_path(@product)
      flash.now[:alert] = "#{I18n.t(".not_updated")}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.destroy
      redirect_to admin_products_path, notice: I18n.t(".destroyed")
    else
      redirect_to admin_products_path, alert: I18n.t(".not_destroyed")
    end
  end

  private

    def set_product
      @product ||= Product.find_by_id(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :public_status, category_ids: [], company_ids: [])
    end

    def set_active_main_menu_item
      @main_menu[:products][:active] = true
    end
end
