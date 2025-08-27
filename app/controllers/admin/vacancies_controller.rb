class Admin::VacanciesController < Admin::BaseController
  add_breadcrumb I18n.t(".vacancy"), :admin_vacancies_path

  skip_before_action :set_active_main_menu_item
  before_action :set_vacancy, only: [ :show, :edit, :update, :destroy ]

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
          sort_column = params[:sort_column] || "updated_at"
          sort_direction = params[:sort_direction] || "desc"

          # Проверка безопасности для сортировки (защита от SQL-инъекций)
          allowed_columns = %w[name updated_at created_at]
          sort_column = "updated_at" unless allowed_columns.include?(sort_column)
          sort_direction = sort_direction.to_s.downcase == "asc" ? "asc" : "desc"

          # Основной запрос с сортировкой
          vacancies = Vacancy.order("#{sort_column} #{sort_direction}")

          # Фильтрация, если есть поисковый запрос
          if search_value.present?
            vacancies = vacancies.where("name LIKE ?", "%#{search_value}%")
          end

          # Общее количество записей без фильтрации (используем кэширование)
          total_records = Rails.cache.fetch("vacancies_count", expires_in: 10.minutes) do
            Vacancy.count
          end

          # Общее количество записей после фильтрации
          filtered_records = search_value.present? ? vacancies.count : total_records

          # Пагинация
          vacancies = vacancies.offset(start).limit(length)

          # Формируем данные для ответа
          data = vacancies.map do |vacancy|
            {
              name: vacancy.name,
              updated_at: I18n.l(vacancy.updated_at, format: :long),
              actions: render_to_string(partial: "admin/vacancies/actions", locals: { vacancy: vacancy }, formats: [ :html ])
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
    unless @vacancy
      redirect_to new_admin_vacancy_path and return
    end

    add_breadcrumb @vacancy.name, admin_vacancy_path(@vacancy)
  end

  def new
    add_breadcrumb I18n.t(".new"), new_admin_vacancy_path

    @vacancy = Vacancy.new
  end

  def create
    @vacancy = Vacancy.new(vacancy_params)

    if @vacancy.save
      redirect_to admin_vacancy_path(@vacancy), notice: I18n.t(".created")
    else
      add_breadcrumb I18n.t(".new"), new_admin_vacancy_path
      flash.now[:alert] = "#{I18n.t(".not_created")}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "#{I18n.t('.edit')}: #{@vacancy.name}", edit_admin_vacancy_path(@vacancy)
  end

  def update
    if @vacancy.update(vacancy_params)
      redirect_to admin_vacancy_path(@vacancy), notice: I18n.t(".updated")
    else
      add_breadcrumb "#{I18n.t('.edit')}: #{@vacancy.name}", admin_vacancy_path(@vacancy)

      flash.now[:alert] = "#{I18n.t(".not_updated")}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @vacancy.destroy
      redirect_to admin_vacancies_path, notice: I18n.t(".destroyed")
    else
      redirect_to admin_vacancies_path, alert: I18n.t(".not_destroyed")
    end
  end

  private

    def set_vacancy
      @vacancy ||= Vacancy.find_by_id(params[:id])
    end

    def vacancy_params
      params.require(:vacancy).permit(
        :public_status,
        *I18n.available_locales.map { |locale| "description_#{locale}" },
        translations_attributes: [ :id, :locale, :name ]
      )
    end
end
