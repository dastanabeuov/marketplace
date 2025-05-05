class Admin::CategoriesController < Admin::BaseController
  add_breadcrumb "<i class='bi bi-list'></i> #{I18n.t('.categories')}".html_safe, :admin_categories_path

  before_action :set_category, only: [ :show, :edit, :update, :destroy ]

  load_and_authorize_resource except: [ :search ]

  def search
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

          # Основной запрос
          categories = Category.order(id: :desc)

          # Фильтрация, если есть поисковый запрос
          if search_value.present?
            categories = categories.where("name LIKE ?", "%#{search_value}%")
          end

          # Общее количество записей без фильтрации (используем кэширование)
          total_records = Rails.cache.fetch("categories_count", expires_in: 10.minutes) do
            Category.count
          end

          # Общее количество записей после фильтрации
          filtered_records = search_value.present? ? categories.count : total_records

          # Пагинация
          categories = categories.offset(start).limit(length)

          # Формируем данные для ответа
          data = categories.map do |category|
            {
              name: category.name,
              updated_at: I18n.l(category.updated_at, format: :long),
              actions: render_to_string(partial: "admin/categories/actions", locals: { category: category }, formats: [ :html ])
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
    add_breadcrumb "#{@category.name}", admin_category_path(@category)
  end

  def new
    add_breadcrumb "#{I18n.t('.new')}", new_admin_category_path

    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_category_path(@category), notice: I18n.t(".created")
    else
      add_breadcrumb "#{I18n.t('.new')}", new_admin_category_path
      flash.now[:alert] = "#{I18n.t(".not_created")}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "#{I18n.t('.edit')}: #{@category.name}", edit_admin_category_path(@category)
  end

  def update
    if @category.update(category_params)
      redirect_to admin_category_path(@category), notice: I18n.t(".updated")
    else
      add_breadcrumb "#{I18n.t('.edit')}: #{@category.name}", admin_category_path(@category)
      flash.now[:alert] = "#{I18n.t(".not_updated")}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      redirect_to admin_categories_path, notice: I18n.t(".destroyed")
    else
      redirect_to admin_categories_path, alert: I18n.t(".not_destroyed")
    end
  end

  private

    def set_category
      @category ||= Category.find_by_id(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :description, :public_status, company_ids: [])
    end

    def set_active_main_menu_item
      @main_menu[:categories][:active] = true
    end
end
