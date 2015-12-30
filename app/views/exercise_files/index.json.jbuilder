json.array!(@exercise_files) do |exercise_file|
  json.extract! exercise_file, :id, :main, :content, :path, :solution, :filetype, :exercise_id
  json.url exercise_file_url(exercise_file, format: :json)
end
