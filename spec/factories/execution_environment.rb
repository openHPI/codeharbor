FactoryBot.define do
  factory :java_8_execution_environment, class: 'ExecutionEnvironment' do
    language { 'Java' }
    version { '1.8' }
  end
end
