module ApplicationHelper
  def nav_link(name, path, html_options = {})
    # Извлекаем контроллер из пути
    path_controller = Rails.application.routes.recognize_path(path)[:controller] rescue nil
    current_controller = controller_name

    # Проверяем активность по странице, пути или контроллеру
    active = current_page?(path) ||
            request.path.start_with?(path) ||
            (path_controller && path_controller == current_controller)

    classes = [ html_options[:class], "nav-link", ("active" if active) ].compact.join(" ")

    link_to name, path, html_options.merge(class: classes)
  end

  def dropdown_nav_link(name, items = [], &block)
    active = items.any? { |item| current_page?(item[:path]) }
    classes = [ "nav-link", "dropdown-toggle", (active ? "active" : nil) ].compact.join(" ")

    content_tag(:li, class: "nav-item dropdown") do
      concat(
        link_to(name, "#",
          class: classes,
          id: "dropdownMenu",
          role: "button",
          data: { bs_toggle: "dropdown" },
          aria: { expanded: active }
        )
      )
      concat(
        content_tag(:ul, class: "dropdown-menu", aria: { labelledby: "dropdownMenu" }) do
          capture(&block)
        end
      )
    end
  end

  def dropdown_item_link(name, path)
    active_class = current_page?(path) ? "active" : ""
    classes = [ "dropdown-item", active_class ].compact.join(" ")

    link_to name, path, class: classes
  end

  def flash_key(key)
    case key.to_sym
    when :notice, :success
      "alert-success"
    when :info
      "alert-info"
    when :warning
      "alert-warning"
    when :error, :alert, :danger
      "alert-danger"
    else
      "alert-primary"
    end
  end

  def full_name(user)
    if user.first_name.present? || user.last_name.present?
      "#{user.first_name} #{user.last_name}".strip
    else
      user.email
    end
  end

  def current_year
    Time.now.year
  end

  def site_name
    Sitename.first.name unless Sitename.count.zero?
  end

  def site_description
    Sitename.first.send("description_#{I18n.locale}") unless Sitename.count.zero?
  end

  def mechanics
    @mechanics = Mechanic.first(10)
  end

  def show_breadcrumbs?
    return false if current_page?(root_path)
    return false if controller_path.start_with?("devise/")
    return false if defined?(Devise) && controller.is_a?(DeviseController)
    true
  end
end
