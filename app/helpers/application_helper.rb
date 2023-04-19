# frozen_string_literal: true

module ApplicationHelper
  # Add an active class when the current page match with the path (also true for the child page)
  def active_class(path)
    current_path = current_page? path
    current_path || request.path.start_with?(path) ? 'active' : ''
  end
end
