FactoryGirl.define do
  factory :only_meta_data, class: 'Exercise' do
  	title 'Some Exercise'
  	description 'Very descriptive'
    maxrating 10
  end
end
