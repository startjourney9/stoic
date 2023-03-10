module ApplicationHelper
  def nav_link(path, &block)
    class_name = current_page?(path) ? 'active' : ''
    haml_tag(:li, class: class_name, &block)
  end

  def fix_old_bootstrap_alert_css(level)
    case level
    when 'notice' then 'success'
    when 'error' then 'danger'
    when 'alert' then 'danger'
    else 'secondary'
    end
  end
end
