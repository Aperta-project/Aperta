module ApplicationHelper
  def active_link_to link_text, path
    link_to_unless_current link_text, path do
      link_to link_text, path, class: 'active'
    end
  end
end
