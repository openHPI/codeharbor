# frozen_string_literal: true

RSpec::Matchers.define :have_form_button do |action: nil|
  match do |page|
    page.has_selector?(:xpath, ".//form[@action='#{action}']/button")
  end

  failure_message do |_page|
    "expected that the page would have a form with the action: #{action}"
  end

  failure_message_when_negated do |_page|
    "expected that the page would not have a form button with the action: #{action}"
  end
end
