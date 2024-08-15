# frozen_string_literal: true

switch_locale do
  json.name t('common.app_name')
  json.description t('application.footer.about.paragraph')
  json.lang I18n.locale
  # Categories: https://github.com/w3c/manifest/wiki/Categories
  json.categories %w[education productivity]
  json.start_url root_url
  json.scope Rails.application.config.relative_url_root
  json.display 'standalone'
  json.orientation 'any'
  json.theme_color '#6C757D'
  json.background_color '#FFFFFF'

  json.icons do
    json.array!([
      {
        src: '/icon.png',
        sizes: '512x512',
        type: 'image/png',
      },
      {
        src: '/icon.svg',
        sizes: 'any',
        type: 'image/svg+xml',
      },
    ])
  end

  json.shortcuts do
    json.array!([
      {
        name: Task.model_name.human(count: :many).capitalize,
        url: tasks_url,
      },
      {
        name: Collection.model_name.human(count: :many).capitalize,
        url: collections_url,
      },
      {
        name: Group.model_name.human(count: :many).capitalize,
        url: groups_url,
      },
    ])
  end

  json.related_applications do
    json.array!([
      # No app for CodeHarbor yet :(, but empty array required for installation prompt
    ])
  end
  json.prefer_related_applications true
end
