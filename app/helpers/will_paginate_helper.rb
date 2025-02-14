# frozen_string_literal: true

module WillPaginateHelper
  class WillPaginateJSLinkRenderer < WillPaginate::ActionView::Bootstrap4LinkRenderer
    def prepare(collection, options, template)
      options[:params] ||= {}
      options[:params]['_'] = nil
      super
    end

    protected

    def link(text, target, attributes = {})
      if target.is_a? Integer
        attributes[:rel] = rel_value(target)
        target = url(target)
      end

      @template.link_to(target, attributes.merge(remote: true)) do # rubocop:disable Rails/HelperInstanceVariable
        text.to_s.html_safe # rubocop:disable Rails/OutputSafety -- the string is already safe and provided by WillPaginate
      end
    end
  end
end
