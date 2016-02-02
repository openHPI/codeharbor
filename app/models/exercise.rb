class Exercise < ActiveRecord::Base
  has_many :exercise_files
  has_many :tests
  has_and_belongs_to_many :labels
  has_many :comments
  has_many :ratings
  belongs_to :user

  def self.search(search)
  	if search
  		results = where('title LIKE ?', "%#{search}%")
      label = Label.find_by(name: search)

      if label
        collection = label.exercises
        results.each do |r|
          collection << r unless collection.find_by(id: r.id)
        end
        return collection
      end
      return results

  	else
      return all
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
