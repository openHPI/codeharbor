# frozen_string_literal: true

json.extract! @message, :id, :text, :sender_id, :recipient_id, :status, :created_at, :updated_at
