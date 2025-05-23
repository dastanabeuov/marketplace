class VacanciesController < ApplicationController
  add_breadcrumb I18n.t(".vacancies"), :vacancies_path

  # skip_before_action :set_active_main_menu_item
  before_action :set_vacancy, only: [ :show ]

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
              actions: render_to_string(partial: "vacancies/actions", locals: { vacancy: vacancy }, formats: [ :html ])
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
    unless @vacancy
      redirect_to root_path and return
    end

    add_breadcrumb @vacancy.name
  end

  private

  def set_vacancy
    @vacancy ||= Vacancy.find_by_id(params[:id])
  end
end
