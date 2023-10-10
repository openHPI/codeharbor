# frozen_string_literal: true

FactoryBot.define do
  factory :task do
    sequence(:title) {|n| "Test Exercise #{n}" }
    description { 'description' }
    user
    uuid { SecureRandom.uuid }
    language { 'de' }

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
          'meta-data': {
            '@xmlns': {CodeOcean: 'custom_namespace.org'},
            'CodeOcean:meta': {
              '$1': 'data',
              'CodeOcean:nest': {
                'CodeOcean:even': {
                  'CodeOcean:deeper': {
                    '$1': 'foobar',
                  },
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
          'submission-restrictions': {
            '@max-size': '50',
            'file-restriction': [
              {
                '@use': 'required',
                '@pattern-format': 'none',
                '$1': 'restriction1',
              },
              {
                '@use': 'optional',
                '@pattern-format': 'posix-ere',
                '$1': 'restriction2',
              },
            ],
            description: {
              '$1': 'desc',
            },
            'internal-description': {
              '$1': 'int-desc',
            },
          },
        }
      end
    end

    trait(:with_external_resources) do
      external_resources do
        {
          'external-resources': {
            'external-resource': [
              {
                '@id': 'external-resource 1',
                '@reference': '1',
                '@used-by-grader': 'true',
                '@visible': 'delayed',
                '@usage-by-lms': 'download',
                'internal-description': {
                  '$1': 'internal-desc',
                },
                'foo:bar': {
                  '@xmlns': {
                    foo: 'urn:custom:foobar',
                  },
                  '@version': '4',
                  'foo:content': {
                    '@xmlns': {
                      foo: 'urn:custom:foobar',
                    }, '$1': 'foobar'
                  },
                },
              },
              {
                '@id': 'external-resource 2',
                '@reference': '2',
                '@used-by-grader': 'false',
                '@visible': 'no',
                '@usage-by-lms': 'edit',
                'internal-description': {
                  '$1': 'internal-desc',
                },
                'foo:bar': {
                  '@xmlns': {
                    foo: 'urn:custom:foobar',
                  },
                  '@version': '5',
                  'foo:content': {
                    '@xmlns': {
                      foo: 'urn:custom:foobar',
                    }, '$1': 'barfoo'
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
          'grading-hints': {
            root: {
              '@function': 'sum',
              'test-ref': [
                {
                  '@ref': '1',
                  '@weight': '0',
                },
                {
                  '@ref': '2',
                  '@weight': '1',
                },
              ],
            },
          },
        }
      end
    end
  end
end
