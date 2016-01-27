class Exercise < ActiveRecord::Base
  has_many :exercise_files
  has_many :labels
  has_many :comments
  has_many :ratings
  belongs_to :user

  def self.search(search)
  	if search
  		where('title LIKE ?', "%#{search}%")
  	else
      all
  	end
  end

  def avg_rating
    if ratings.empty?
      return 0
    else
      result = 1.0 * ratings.map(&:rating).inject(:+) / ratings.size
      return result.round(1)
    end
  end

  def round_avg_rating
    (avg_rating*2).round / 2.0
  end
end
