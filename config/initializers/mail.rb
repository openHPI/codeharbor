# frozen_string_literal: true

yaml_file = File.read(Rails.root.join('config/action_mailer.yml'))
options = YAML.safe_load(yaml_file, aliases: true, permitted_classes: [Symbol])[Rails.env]

Rails.configuration.action_mailer.delivery_method = options.delete('delivery_method')

if options.key? 'smtp_settings'
  Rails.configuration.action_mailer[:smtp_settings] = {}
  unless options.nil?
    options['smtp_settings'].each do |name, value|
      Rails.configuration.action_mailer[:smtp_settings][name.to_sym] = value
    end
  end
end

if options.key? 'default_options'
  Rails.configuration.action_mailer[:default_options] = {}
  unless options.nil?
    options['default_options'].each do |name, value|
      Rails.configuration.action_mailer[:default_options][name.to_sym] = value
    end
  end
end

if options.key? 'sendmail_settings'
  Rails.configuration.action_mailer[:sendmail_settings] = {}
  unless options.nil?
    options['sendmail_settings'].each do |name, value|
      Rails.configuration.action_mailer[:sendmail_settings][name.to_sym] = value
    end
  end
end

if options.key? 'default_url_options'
  Rails.configuration.action_mailer[:default_url_options] = {}
  unless options.nil?
    options['default_url_options'].each do |name, value|
      Rails.configuration.action_mailer[:default_url_options][name.to_sym] = value
    end
  end
end
