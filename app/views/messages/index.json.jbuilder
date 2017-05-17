json.array!(@messages) do |message|
  json.extract! message, :id, :text, :sender_id, :recipient_id, :status
  json.url message_url(message, format: :json)
end
