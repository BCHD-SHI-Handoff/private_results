module ApplicationHelper
  def active_or_blank(link_path)
    current_page?(link_path) ? "active" : ""
  end
end
