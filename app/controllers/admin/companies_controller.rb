class Admin::CompaniesController < Admin::BaseController
  add_breadcrumb "#{I18n.t('.companies')}", :admin_companies_path

  before_action :set_company, only: [ :show, :edit, :update, :destroy ]

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

          # Основной запрос
          companies = Company.order(id: :desc)

          # Фильтрация, если есть поисковый запрос
          if search_value.present?
            companies = companies.where("name LIKE ?", "%#{search_value}%")
          end

          # Общее количество записей без фильтрации (используем кэширование)
          total_records = Rails.cache.fetch("companies_count", expires_in: 10.minutes) do
            Company.count
          end

          # Общее количество записей после фильтрации
          filtered_records = search_value.present? ? companies.count : total_records

          # Пагинация
          companies = companies.offset(start).limit(length)

          # Формируем данные для ответа
          data = companies.map do |company|
            {
              name: company.name,
              updated_at: I18n.l(company.updated_at, format: :long),
              actions: render_to_string(partial: "admin/companies/actions", locals: { company: company }, formats: [ :html ])
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
    add_breadcrumb "#{@company.name}", admin_company_path(@company)
  end

  def new
    add_breadcrumb "#{I18n.t('.new')}", new_admin_company_path

    @company = Company.new
  end

  def create
    @company = Company.new(company_params)

    if @company.save
      redirect_to admin_company_path(@company), notice: I18n.t(".created")
    else
      add_breadcrumb "#{I18n.t('.new')}", new_admin_company_path
      render :new, alert: I18n.t(".not_created"), status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "#{I18n.t('.edit')}: #{@company.name}", edit_admin_company_path(@company)
  end

  def update
    if @company.update(company_params)
      add_breadcrumb "#{I18n.t('.show')}: #{@company.name}", admin_company_path(@company)
      redirect_to admin_company_path(@company), notice: I18n.t(".updated")
    else
      add_breadcrumb "#{I18n.t('.edit')}: #{@company.name}", admin_company_path(@company)
      render :edit, alert: I18n.t(".not_updated"), status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy
    redirect_to admin_companies_path, notice: I18n.t(".destroyed")
  end

  private

    def set_company
      @company ||= Company.find_by_id(params[:id])
    end

    def company_params
      params.require(:company).permit(:name, :description, :public_status)
    end

    def set_active_main_menu_item
      @main_menu[:companies][:active] = true
    end
end
