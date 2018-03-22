FactoryBot.define do
  factory :simple_description, class: 'Description' do
  	text "Very descriptive"
    language "en"
  end

  factory :codeharbor_description, class: 'Description' do
    text "This is a test-exercise for export to codeharbor. All important fields are set. Replace the x with the right word."
    language "en"
  end
end
