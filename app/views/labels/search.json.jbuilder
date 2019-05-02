# frozen_string_literal: true

json.array!(@labels) do |label|
  json.name label.name
end
