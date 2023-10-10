# frozen_string_literal: true

yaml_file = Rails.root.join('config/action_mailer.yml').read
options = YAML.safe_load(yaml_file, aliases: true, permitted_classes: [Symbol])[Rails.env]

options.each do |key, value|
  CodeHarbor::Application.config.action_mailer.send(:"#{key}=", value.respond_to?(:symbolize_keys) ? value.symbolize_keys : value)
end
