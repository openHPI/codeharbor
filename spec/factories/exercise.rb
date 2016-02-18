FactoryGirl.define do
  factory :only_meta_data, class: 'Exercise' do
  	title 'Some Exercise'
    maxrating 10
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
    end
  end

  factory :exercise_with_single_java_main_file, class: 'Exercise' do
    title 'Some Exercise'
    after(:create) do |exercise|
      create(:simple_description, exercise: exercise)
      create(:single_java_main_file, exercise: exercise)
    end
  end

end
