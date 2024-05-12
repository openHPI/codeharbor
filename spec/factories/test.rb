# frozen_string_literal: true

FactoryBot.define do
  factory :test, class: 'Test' do
    task
    title { 'title' }
    sequence(:xml_id) {|n| "test_#{n}" }

    trait(:with_meta_data) do
      meta_data do
        {
          '@@order' => %w[test-meta-data],
          'test-meta-data' => {
            '@@order' => %w[namespace:meta namespace:nested],
            '@xmlns' => {'namespace' => 'custom_namespace.org'},
            'namespace:meta' => {
              '@@order' => %w[$1],
              '$1' => 'data',
            },
            'namespace:nested' => {
              '@@order' => %w[namespace:foo namespace:test],
              'namespace:foo' => {
                '@@order' => %w[$1],
                '$1' => 'bar',
              },
              'namespace:test' => {
                '@@order' => %w[namespace:abc],
                'namespace:abc' => {
                  '@@order' => %w[$1],
                  '$1' => '123',
                },
              },
            },
          },
        }
      end
    end

    trait :with_content do
      test_type { 'test_type' }
      description { 'description' }
      internal_description { 'internal_description' }

      files { [build(:task_file, :exportable)] }
    end

    trait :with_unittest do
      test_type { 'unittest' }
      configuration do
        {
          '@@order' => %w[unit:unittest],
          'unit:unittest' => {
            '@@order' => %w[unit:entry-point],
            '@xmlns' => {'unit' => 'urn:proforma:tests:unittest:v1.1'},
            '@framework' => 'JUnit',
            '@version' => '4.10',
            'unit:entry-point' => {
              '@@order' => %w[$1],
              '$1' => 'HelloWorldTest',
            },
          },
        }
      end
    end

    trait(:with_java_checkstyle) do
      test_type { 'java-checkstyle' }
      configuration do
        {
          '@@order' => %w[check:java-checkstyle],
          'check:java-checkstyle' => {
            '@@order' => %w[check:max-checkstyle-warnings],
            '@xmlns' => {'check' => 'urn:proforma:tests:java-checkstyle:v1.1'},
            '@version' => '3.14',
            'check:max-checkstyle-warnings' => {
              '@@order' => %w[$1],
              '@xmlns' => {'unit' => 'urn:proforma:tests:java-checkstyle:v1.1'},
              '$1' => '4',
            },
          },
        }
      end
    end

    trait(:with_regexptest) do
      test_type { 'regexptest' }
      configuration do
        {
          '@@order' => %w[regex:regexptest],
          'regex:regexptest' => {
            '@@order' => %w[regex:entry-point regex:parameter regex:regular-expressions],
            '@xmlns' => {'regex' => 'urn:proforma:tests:regexptest:v0.9'},
            'regex:entry-point' => {
              '@@order' => %w[$1],
              '$1' => 'HelloWorldTest',
            },
            'regex:parameter' => {
              '@@order' => %w[$1],
              '$1' => 'gui',
            },
            'regex:regular-expressions' => {
              '@@order' => %w[regex:regexp-disallow],
              'regex:regexp-disallow' => {
                '@@order' => %w[$1],
                '@case-insensitive' => 'true',
                '@dotall' => 'true',
                '@multiline' => 'true',
                '@free-spacing' => 'true',
                '$1' => 'foobar',
              },
            },
          },
        }
      end
    end

    trait(:with_multiple_custom_configurations) do
      configuration do
        {
          '@@order' => %w[unit:unittest regex:regexptest check:java-checkstyle],
          'unit:unittest' => {
            '@@order' => %w[unit:entry-point],
            '@xmlns' => {'unit' => 'urn:proforma:tests:unittest:v1.1'},
            '@version' => '4.10',
            '@framework' => 'JUnit',
            'unit:entry-point' => {
              '@@order' => %w[$1],
              '$1' => 'HelloWorldTest',
            },
          },
          'regex:regexptest' =>
            {
              '@@order' => %w[regex:entry-point regex:parameter regex:regular-expressions],
              '@xmlns' => {'regex' => 'urn:proforma:tests:regexptest:v0.9'},
              'regex:entry-point' => {
                '@@order' => %w[$1],
                '$1' => 'HelloWorldTest',
              },
              'regex:parameter' => {
                '@@order' => %w[$1],
                '$1' => 'gui',
              },
              'regex:regular-expressions' => {
                '@@order' => %w[regex:regexp-disallow],
                'regex:regexp-disallow' => {
                  '@@order' => %w[$1],
                  '$1' => 'foobar',
                  '@dotall' => 'true',
                  '@multiline' => 'true',
                  '@free-spacing' => 'true',
                  '@case-insensitive' => 'true',
                },
              },
            },
          'check:java-checkstyle' => {
            '@@order' => %w[check:max-checkstyle-warnings],
            '@xmlns' => {'check' => 'urn:proforma:tests:java-checkstyle:v1.1'},
            '@version' => '3.14',
            'check:max-checkstyle-warnings' => {
              '@@order' => %w[$1],
              '$1' => '4',
            },
          },
        }
      end
    end
  end
end
