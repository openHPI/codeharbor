json.array!(@execution_environments) do |execution_environment|
  json.extract! execution_environment, :id, :language, :version
  json.url execution_environment_url(execution_environment, format: :json)
end
