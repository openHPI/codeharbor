# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    sequence(:title) {|n| "Test Exercise #{n}" }
    description { 'description' }
    user
    uuid { SecureRandom.uuid }
    language { 'de' }
    meta_data { {} }

    trait :with_content do
      internal_description { 'internal_description' }
    end

    trait :empty do
      title {}
      description {}
    end

    trait :with_labels do
      labels { build_list(:label, 3) }
    end

    trait(:with_meta_data) do
      meta_data do
        {
          '@@order' => %w[meta-data],
          'meta-data' => {
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

    trait(:with_submission_restrictions) do
      submission_restrictions do
        {
          '@@order' => %w[submission-restrictions],
          'submission-restrictions' => {
            '@@order' => %w[file-restriction description internal-description],
            '@max-size' => '50',
            'file-restriction' => [
              {
                '@@order' => %w[$1],
                '@use' => 'required',
                '@pattern-format' => 'none',
                '$1' => 'restriction1',
              },
              {
                '@@order' => %w[$1],
                '@use' => 'optional',
                '@pattern-format' => 'posix-ere',
                '$1' => 'restriction2',
              },
            ],
            'description' => {
              '@@order' => %w[$1],
              '$1' => 'desc',
            },
            'internal-description' => {
              '@@order' => %w[$1],
              '$1' => 'int-desc',
            },
          },
        }
      end
    end

    trait(:with_external_resources) do
      external_resources do
        {
          '@@order' => %w[external-resources],
          'external-resources' => {
            '@@order' => %w[external-resource],
            '@xmlns' => {'foo' => 'urn:custom:foobar'},
            'external-resource' => [
              {
                '@@order' => %w[internal-description foo:bar],
                '@id' => 'external-resource 1',
                '@reference' => '1',
                '@used-by-grader' => 'true',
                '@visible' => 'delayed',
                '@usage-by-lms' => 'download',
                'internal-description' => {
                  '@@order' => %w[$1],
                  '$1' => 'internal-desc',
                },
                'foo:bar' => {
                  '@@order' => %w[foo:content],
                  '@version' => '4',
                  'foo:content' => {
                    '@@order' => %w[$1],
                    '$1' => 'foobar',
                  },
                },
              },
              {
                '@@order' => %w[internal-description foo:bar],
                '@id' => 'external-resource 2',
                '@reference' => '2',
                '@used-by-grader' => 'false',
                '@visible' => 'no',
                '@usage-by-lms' => 'edit',
                'internal-description' => {
                  '@@order' => %w[$1],
                  '$1' => 'internal-desc',
                },
                'foo:bar' => {
                  '@version' => '5',
                  '@@order' => %w[foo:content],
                  'foo:content' => {
                    '@@order' => %w[$1],
                    '$1' => 'barfoo',
                  },
                },
              },
            ],
          },
        }
      end
    end

    trait(:with_grading_hints) do
      grading_hints do
        {
          '@@order' => %w[grading-hints],
          'grading-hints' => {
            '@@order' => %w[root],
            'root' => {
              '@@order' => %w[test-ref],
              '@function' => 'sum',
              'test-ref' => [
                {
                  '@ref' => '1',
                  '@weight' => '0',
                },
                {
                  '@ref' => '2',
                  '@weight' => '1',
                },
              ],
            },
          },
        }
      end
    end
  end
end
