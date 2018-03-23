class Description < ApplicationRecord
  belongs_to :exercise

  LANGUAGES= ['en', 'de','fr', 'es', 'ja', 'cn']
  LANGUAGES.freeze

end
