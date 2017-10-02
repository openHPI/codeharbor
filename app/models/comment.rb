class Comment < ActiveRecord::Base
  validates :text, presence: true

  belongs_to :exercise
  belongs_to :user

  def self.search(search)
    if search
      where('text LIKE ?', "%#{search}%")
    else
      all
    end
  end
end
