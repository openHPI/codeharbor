class Description < ActiveRecord::Base
  belongs_to :exercise

  LANGUAGES= ['en', 'de','fr', 'es', 'ja', 'cn']
  LANGUAGES.freeze

end
