require 'nokogiri'

class Exercise < ActiveRecord::Base
  has_many :exercise_files
  has_many :tests
  has_and_belongs_to_many :labels
  has_many :comments
  has_many :ratings
  #has_and_belongs_to_many :collections
  #has_and_belongs_to_many :carts
  belongs_to :user
  belongs_to :execution_environment
  has_many :descriptions

  accepts_nested_attributes_for :descriptions, allow_destroy: true

  def self.search(search)
  	if search
  		results = where('lower(title) LIKE ?', "%#{search.downcase}%")
      label = Label.find_by('lower(name) = ?', search.downcase)

      if label
        collection = Label.find_by('lower(name) = ?', search.downcase).exercises
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

  def add_descriptions(description_array)
    description_array.each do |key, array|
      destroy = array[:_destroy]
      id = array[:id]
      
      if id
        description = Description.find(id)
        if destroy
          description.destroy
        else
          description.update(text: array[:text])
        end
      else
        descriptions << Description.create(text: array[:text]) unless destroy
      end
    end
  end

  def to_proforma_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.root('xmlns:p' => 'urn:proforma:task:v0.9.4') {
        p = xml['p']
        p.task {
          p.description(self.description)
          p.send('grading-hints', 'max-rating' => self.maxrating.to_s)
          p.send('meta-data') {
            p.title(self.title)
          }
        }
      }
    end
    return builder.to_xml
  end

end
