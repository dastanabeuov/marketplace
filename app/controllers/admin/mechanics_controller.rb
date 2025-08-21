class Admin::MechanicsController < Admin::BaseController
  include AttachableImageRemoval

  add_breadcrumb I18n.t(".mechanic"), :admin_mechanics_path

  skip_before_action :set_active_main_menu_item
  before_action :set_mechanic, only: [ :show, :edit, :update, :destroy ]
  # before_action :check_singleton_limit, only: [ :new, :create ]

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
          allowed_columns = %w[name updated_at created_at price]
          sort_column = "updated_at" unless allowed_columns.include?(sort_column)
          sort_direction = sort_direction.to_s.downcase == "asc" ? "asc" : "desc"

          # Основной запрос с сортировкой
          mechanics = Mechanic.order("#{sort_column} #{sort_direction}")

          # Фильтрация, если есть поисковый запрос
          if search_value.present?
            mechanics = mechanics.where("name LIKE ?", "%#{search_value}%")
          end

          # Общее количество записей без фильтрации
          total_records = Rails.cache.fetch("mechanics_count", expires_in: 10.minutes) do
            Mechanic.count
          end

          # Общее количество записей после фильтрации
          filtered_records = search_value.present? ? mechanics.count : total_records

          # Пагинация
          mechanics = mechanics.offset(start).limit(length)

          # Формируем данные для ответа
          data = mechanics.map do |mechanic|
            {
              name: mechanic.name,
              updated_at: I18n.l(mechanic.updated_at, format: :long),
              actions: render_to_string(partial: "admin/mechanics/actions", locals: { mechanic: mechanic }, formats: [ :html ])
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
    unless @mechanic
      redirect_to new_admin_mechanic_path and return
    end

    add_breadcrumb @mechanic.name, admin_mechanic_path(@mechanic)
  end

  def new
    add_breadcrumb I18n.t(".new"), :new_admin_mechanic_path
    @mechanic = Mechanic.new
  end

  def create
    @mechanic = Mechanic.new(mechanic_params)
    if @mechanic.save
      redirect_to admin_mechanic_path, notice: I18n.t(".created")
    else
      add_breadcrumb I18n.t(".new"), new_admin_mechanic_path
      flash.now[:alert] = "#{I18n.t(".not_created")}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_breadcrumb "#{I18n.t('.edit')}: #{@mechanic.name}", edit_admin_mechanic_path(@mechanic)
  end

  def update
    if @mechanic.update(mechanic_params)
      redirect_to admin_mechanic_path, notice: I18n.t(".updated")
    else
      add_breadcrumb "#{I18n.t('.edit')}: #{@mechanic.name}", admin_mechanic_path(@mechanic)
      flash.now[:alert] = "#{I18n.t(".not_updated")}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @mechanic.destroy
      redirect_to new_admin_mechanic_path, notice: I18n.t(".destroyed")
    else
      redirect_to new_admin_mechanic_path, alert: I18n.t(".not_destroyed")
    end
  end

  private

  def set_mechanic
    @mechanic = Mechanic.find_by_id(params[:id])
  end

  # def check_singleton_limit
  #   if Mechanic.exists?
  #     redirect_to admin_mechanic_path, alert: I18n.t(".check_singleton_limit")
  #   end
  # end

  def mechanic_params
    params.require(:mechanic).permit(:image, :name, :description)
  end
end
