# frozen_string_literal: true

module WillPaginateHelper
  class WillPaginateJSLinkRenderer < WillPaginate::ActionView::LinkRenderer
    def prepare(collection, options, template)
      options[:params] ||= {}
      options[:params]['_'] = nil
      super(collection, options, template)
    end

    protected

    def link(text, target, attributes = {})
      if target.is_a? Integer
        attributes[:rel] = rel_value(target)
        target = url(target)
      end

      @template.link_to(target, attributes.merge(remote: true)) do
        # rubocop:disable Rails/OutputSafety
        text.to_s.html_safe
        # rubocop:enable Rails/OutputSafety
      end
    end
  end

  def js_will_paginate(collection, options = {})
    will_paginate(collection, options.merge(renderer: WillPaginateHelper::WillPaginateJSLinkRenderer))
  end
end
