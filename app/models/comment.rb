# frozen_string_literal: true

class Comment < ApplicationRecord
  validates :text, presence: true

  belongs_to :task
  belongs_to :user

  def self.search(search)
    if search
      where('text LIKE ?', "%#{search}%")
    else
      all
    end
  end
end
