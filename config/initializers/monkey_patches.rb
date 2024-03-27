# frozen_string_literal: true

unless Array.respond_to?(:average)
  class Array
    def average
      sum / length if present?
    end
  end
end

module WillPaginate
  module ActionView
    class Bootstrap4LinkRenderer
      def previous_or_next_page(page, text, classname, aria_label = nil)
        tag :li, link(text, page || '#', class: 'page-link', 'aria-label': aria_label), class: [(classname[0..3] if @options[:page_links]), (classname if @options[:page_links]), ('disabled' unless page), 'page-item'].join(' ')
      end
    end
  end
end

# rubocop:disable all
# To avoid Kramdown escaping symbols
module Kramdown
  module Converter
    class Kramdown
      def convert_text(el, opts)
        if opts[:raw_text]
          el.value
        else
          el.value.gsub(/\A\n/) do
            opts[:prev] && opts[:prev].type == :br ? '' : "\n"
          end.gsub(/\s+/, ' ').gsub(ESCAPED_CHAR_RE) do
            $1 || !opts[:prev] || opts[:prev].type == :br ? "#{$1 || $2}" : $&
          end
        end
      end
    end
  end
end
# rubocop:enable all
