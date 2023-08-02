# frozen_string_literal: true

FactoryBot.define do
  factory :test, class: 'Test' do
    title { 'title' }
    sequence(:xml_id) {|n| "test_#{n}" }

    trait :with_content do
      test_type { 'test_type' }
      description { 'description' }
      internal_description { 'internal_description' }
    end

    trait :with_unittest do
      test_type { 'unittest' }
      configuration do
        {
          'unit:unittest' =>
            {
              '@xmlns' => {'unit' => 'urn:proforma:tests:unittest:v1.1'},
              '@framework' => 'JUnit',
              '@version' => '4.12',
              'unit:entry-point' => {
                '@xmlns' => {'unit' => 'urn:proforma:tests:unittest:v1.1'},
                '$1' => 'reverse_task.MyStringTest',
              },
            },
        }
      end
    end
    trait(:with_multiple_custom_configurations) do
      configuration do
        {
          'unit:unittest' => {
            '@xmlns' => {'unit' => 'urn:proforma:tests:unittest:v1.1'},
            '@version' => '4.10',
            '@framework' => 'JUnit',
            'unit:entry-point' => {
              '$1' => 'HelloWorldTest',
              '@xmlns' => {'unit' => 'urn:proforma:tests:unittest:v1.1'},
            },
          },
          'regex:regexptest' =>
            {
              '@xmlns' => {'regex' => 'urn:proforma:tests:regexptest:v0.9'},
              'regex:entry-point' => {
                '$1' => 'HelloWorldTest',
                '@xmlns' => {'regex' => 'urn:proforma:tests:regexptest:v0.9'},
              },
              'regex:parameter' => {
                '$1' => 'gui',
                '@xmlns' => {'regex' => 'urn:proforma:tests:regexptest:v0.9'},
              },
              'regex:regular-expressions' => {
                '@xmlns' => {'regex' => 'urn:proforma:tests:regexptest:v0.9'},
                'regex:regexp-disallow' => {
                  '$1' => 'foobar',
                  '@xmlns' => {'regex' => 'urn:proforma:tests:regexptest:v0.9'},
                  '@dotall' => 'true',
                  '@multiline' => 'true',
                  '@free-spacing' => 'true',
                  '@case-insensitive' => 'true',
                },
              },
            },
          'check:java-checkstyle' => {
            '@xmlns' => {'check' => 'urn:proforma:tests:java-checkstyle:v1.1'},
            '@version' => '3.14',
            'check:max-checkstyle-warnings' => {
              '$1' => '4',
              '@xmlns' => {'check' => 'urn:proforma:tests:java-checkstyle:v1.1'},
            },
          },
        }
      end
    end
  end
end
