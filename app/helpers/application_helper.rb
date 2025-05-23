module ApplicationHelper
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

  def current_year
    Time.now.year
  end

  def site_name
    Sitename.first.name unless Sitename.count.zero?
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
