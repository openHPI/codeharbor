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

  def created
    time = (Time.parse(DateTime.now.to_s) - Time.parse(self.created_at.to_s))/60
    time = time.to_i
    if time < 1
      "less than a Minute ago"
    elsif time < 60
      time.to_s + " minutes ago"
    elsif time < 1440
      (time/60).to_s + " hours ago"
    elsif time < 43200
      (time/1440).to_s + " days ago"
    elsif time < 518400
      (time/43200).to_s + " month ago"
    else
      (time/518400).to_s + " years ago"
    end
  end
end
