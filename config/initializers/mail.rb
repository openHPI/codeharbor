# frozen_string_literal: true

options = YAML.load_file(Rails.root.join('config/action_mailer.yml'))[Rails.env]

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
