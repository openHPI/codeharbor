# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bridges::Oai::OaiController do
  render_views

  before { stub_const('Bridges::Oai::OaiController::MAX_RECORDS_PER_RESPONSE', 5) }

  error_response_schema = Nokogiri::XML::Schema(File.open(Bridges::Oai::OaiController::ERROR_RESPONSE_XSD))
  successful_response_schema = Nokogiri::XML::Schema(File.open(Bridges::Oai::OaiController::SUCCESSFUL_RESPONSE_XSD))

  shared_examples 'a successful OAI-PMH response' do
    it 'returns a valid OAI-PMH response' do
      get_request
      expect(successful_response_schema.validate(Nokogiri::XML(response.body))).to be_empty
    end
  end

  shared_examples 'a valid OAI-PMH error' do |expected_error_code|
    it 'returns a valid OAI-PMH error' do
      get_request
      expect(error_response_schema.validate(Nokogiri::XML(response.body))).to be_empty
    end

    it "returns the error code '#{expected_error_code}'" do
      get_request
      xml = Nokogiri::XML(response.body)
      expect(xml.xpath('//xmlns:error').first['code']).to eq(expected_error_code)
    end
  end

  shared_examples 'a valid OAI-PMH error if one of the parameters is missing' do |parameters|
    parameters.each do |param|
      context "when #{param} parameter is missing" do
        let(param) { nil }

        it_behaves_like 'a valid OAI-PMH error', 'badArgument'
      end
    end
  end

  describe 'GET bridges/oai' do
    subject(:get_request) { get :handle_request, params: request_params }

    let(:request_params) { {verb:, identifier:, metadataPrefix: metadata_prefix, from:, until:, set:}.compact }
    let(:metadata_prefix) { nil }
    let(:identifier) { nil }
    let(:from) { nil }
    let(:until) { nil }
    let(:set) { nil }
    let!(:tasks) do
      [
        create(:task, updated_at: Time.utc(2021), access_level: :public),
        create(:task, updated_at: Time.utc(2023), access_level: :public),
      ]
    end

    context 'when verb is GetRecord' do
      let(:verb) { 'GetRecord' }
      let(:metadata_prefix) { :oai_dc }
      let(:identifier) { task.uuid }

      let(:access_level) { :public }
      let(:task) { create(:task, access_level:) }

      it_behaves_like 'a valid OAI-PMH error if one of the parameters is missing', %i[identifier metadata_prefix]

      context 'when task is public' do
        it_behaves_like 'a successful OAI-PMH response'
      end

      context 'when task is private' do
        let(:access_level) { :private }

        it_behaves_like 'a valid OAI-PMH error', 'idDoesNotExist'
      end

      context 'when requesting a non-existing record' do
        let(:identifier) { 'invalid uuid' }

        it_behaves_like 'a valid OAI-PMH error', 'idDoesNotExist'
      end

      context 'when format requested is IEEE LOM' do
        let(:metadata_prefix) { :lom }

        context 'when task is public' do
          it_behaves_like 'a successful OAI-PMH response'
        end
      end

      context 'when format requested is invalid' do
        let(:metadata_prefix) { :invalid }

        context 'when task is public' do
          it_behaves_like 'a valid OAI-PMH error', 'cannotDisseminateFormat'
        end
      end
    end

    context 'when verb is Identify' do
      let(:verb) { 'Identify' }

      it_behaves_like 'a successful OAI-PMH response'
    end

    context 'when verb is ListIdentifiers' do
      let(:verb) { 'ListIdentifiers' }
      let(:metadata_prefix) { :oai_dc }

      it_behaves_like 'a valid OAI-PMH error if one of the parameters is missing', %i[metadata_prefix]

      context 'with set' do
        context 'with task as set' do
          let(:set) { 'task' }

          it_behaves_like 'a successful OAI-PMH response'

          it 'contains all task identifiers' do
            get_request
            xml = Nokogiri::XML(response.body)
            expect(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text)).to match_array(tasks.map(&:uuid))
          end
        end

        context 'with specific label as set' do
          let(:set) { "task:label:#{label.id}" }

          let(:label) { create(:label) }
          let!(:matching_task) { create(:task, updated_at: Time.utc(2023), access_level: :public, labels: [label]) }

          it_behaves_like 'a successful OAI-PMH response'

          it 'contains exactly the matching task identifier' do
            get_request
            xml = Nokogiri::XML(response.body)
            expect(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text)).to contain_exactly(matching_task.uuid)
          end
        end
      end

      context 'without time bounds' do
        it_behaves_like 'a successful OAI-PMH response'

        it 'contains all task identifiers' do
          get_request
          xml = Nokogiri::XML(response.body)
          expect(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text)).to match_array(tasks.map(&:uuid))
        end
      end

      context 'with time bounds matching only one task' do
        let(:from) { Time.utc(2022).iso8601 }
        let(:until) { Time.utc(2024).iso8601 }

        it_behaves_like 'a successful OAI-PMH response'

        it 'contains exactly the matching task identifiers' do
          get_request
          xml = Nokogiri::XML(response.body)
          expect(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text)).to contain_exactly(tasks.second.uuid)
        end
      end

      context 'with time bounds matching no record' do
        let(:from) { Time.utc(2100).iso8601 }

        it_behaves_like 'a valid OAI-PMH error', 'noRecordsMatch'
      end

      context 'with invalid time bounds for the from parameter' do
        let(:from) { Time.utc(2022).rfc822 }

        it_behaves_like 'a valid OAI-PMH error', 'badArgument'
      end

      context 'with invalid time bounds for the until parameter' do
        let(:until) { Time.utc(2022).rfc822 }

        it_behaves_like 'a valid OAI-PMH error', 'badArgument'
      end

      context 'with equal time bounds matching exactly one task' do
        let(:from) { tasks.first.updated_at.iso8601 }
        let(:until) { from }

        it_behaves_like 'a successful OAI-PMH response'

        it 'contains exactly the matching task identifier' do
          get_request
          xml = Nokogiri::XML(response.body)
          expect(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text)).to contain_exactly(tasks.first.uuid)
        end
      end

      context 'when more than the maximum number of records are returned' do
        subject(:request_lambda) do
          lambda {|params|
            get(:handle_request, params:)
            xml = Nokogiri::XML(response.body)
            token = xml.xpath('//xmlns:resumptionToken').text
            [xml, token]
          }
        end

        let(:tasks) { create_list(:task, described_class::MAX_RECORDS_PER_RESPONSE + 2, access_level: :public) }

        it_behaves_like 'a successful OAI-PMH response'

        it 'returns a resumptionToken' do
          get_request
          xml = Nokogiri::XML(response.body)
          expect(xml.xpath('//xmlns:resumptionToken')).to be_present
        end

        context 'when parameters are set' do
          let(:from) { tasks.first.updated_at.iso8601 }
          let(:until) { Time.zone.now.iso8601 }
          let(:set) { 'Task' }

          it_behaves_like 'a successful OAI-PMH response'

          it 'includes all parameters in the resumptionToken' do
            _, token = request_lambda.call(request_params)
            token_hash = JSON.parse(Base64.decode64(token)).symbolize_keys
            expect(token_hash).to include(request_params.transform_values(&:to_s))
            expect(token_hash).to have_key(:last_id)
            expect(token_hash).to have_key(:ts_from)
            expect(token_hash).to have_key(:ts_until)
          end
        end

        context 'when the records do not change between requests' do
          it 'returns exactly all records' do
            returned_records = []

            xml, token = request_lambda.call(request_params)
            returned_records.concat(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text))

            xml, = request_lambda.call({verb:, resumptionToken: token})
            returned_records.concat(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text))

            expect(returned_records).to match_array(tasks.map(&:uuid))
          end

          it 'returns an empty resumptionToken in the final response' do
            _, token = request_lambda.call(request_params)
            _, token = request_lambda.call({verb:, resumptionToken: token})

            expect(token).to be_empty
          end
        end

        context 'when records change between requests' do
          let(:records_changed_after_their_return) { [tasks.first] }
          let(:records_changed_before_their_return) { [tasks[described_class::MAX_RECORDS_PER_RESPONSE + 1]] }
          let(:changed_records) { records_changed_after_their_return + records_changed_before_their_return }
          let(:expected_records) { tasks - records_changed_before_their_return }

          it 'returns exactly all records that did not change before they were returned' do
            returned_records = []

            xml, token = request_lambda.call(request_params)
            returned_records.concat(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text))

            changed_records.each {|task| task.update(title: 'Some new title') }

            xml, = request_lambda.call({verb:, resumptionToken: token})
            returned_records.concat(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text))

            expect(returned_records).to match_array(expected_records.map(&:uuid))
          end
        end

        context 'when last response is empty because of changes' do
          let(:changed_records) { tasks[described_class::MAX_RECORDS_PER_RESPONSE..] }

          it 'does not return an error' do
            _, token = request_lambda.call(request_params)
            changed_records.each {|task| task.update(title: 'Some new title') }
            xml, = request_lambda.call({verb:, resumptionToken: token})

            expect(xml.xpath('//xmlns:header//xmlns:identifier')).to be_empty
            expect(xml.xpath('//xmlns:error')).to be_empty
          end
        end
      end

      context 'when sending an invalid resumptionToken' do
        context 'when the resumptionToken is not a JSON' do
          let(:request_params) { {verb:, resumptionToken: Base64.encode64('invalid token')} }

          it_behaves_like 'a valid OAI-PMH error', 'badResumptionToken'
        end

        context 'when the resumptionToken contains an invalid timestamp' do
          let(:token_hash) { {last_id: 0, ts_from: 'invalid', ts_until: 'invalid'} }
          let(:request_params) { {verb:, resumptionToken: Base64.encode64(token_hash.to_json)} }

          it_behaves_like 'a valid OAI-PMH error', 'badResumptionToken'
        end
      end
    end

    context 'when verb is ListMetadataFormats' do
      let(:verb) { 'ListMetadataFormats' }

      let(:task) { create(:task, updated_at: Time.utc(2021), access_level: :public) }

      context 'without a specific identifier' do
        it_behaves_like 'a successful OAI-PMH response'

        it 'returns oai_dc and lom as metadata prefixes' do
          get_request
          xml = Nokogiri::XML(response.body)
          expect(xml.xpath('//xmlns:metadataFormat//xmlns:metadataPrefix').map(&:text)).to contain_exactly('oai_dc', 'lom')
        end
      end

      context 'with valid identifier' do
        let(:identifier) { task.uuid }

        it_behaves_like 'a successful OAI-PMH response'

        it 'returns oai_dc and lom as metadata prefixes' do
          get_request
          xml = Nokogiri::XML(response.body)
          expect(xml.xpath('//xmlns:metadataFormat//xmlns:metadataPrefix').map(&:text)).to contain_exactly('oai_dc', 'lom')
        end
      end

      context 'with invalid identifier' do
        let(:identifier) { 'not existing uuid' }

        it_behaves_like 'a valid OAI-PMH error', 'idDoesNotExist'
      end
    end

    context 'when verb is ListRecords' do
      let(:verb) { 'ListRecords' }
      let(:metadata_prefix) { :oai_dc }

      it_behaves_like 'a valid OAI-PMH error if one of the parameters is missing', %i[metadata_prefix]

      context 'with set' do
        context 'with task as set' do
          let(:set) { 'task' }

          it_behaves_like 'a successful OAI-PMH response'

          it 'contains all task identifiers' do
            get_request
            xml = Nokogiri::XML(response.body)
            expect(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text)).to match_array(tasks.map(&:uuid))
            expect(xml.xpath('//dc:identifier', 'dc' => 'http://purl.org/dc/elements/1.1/').map(&:text)).to match_array(tasks.map(&:uuid))
          end
        end

        context 'with specific label as set' do
          let(:set) { "task:label:#{label.id}" }

          let(:label) { create(:label) }
          let!(:matching_task) { create(:task, updated_at: Time.utc(2023), access_level: :public, labels: [label]) }

          it_behaves_like 'a successful OAI-PMH response'

          it 'contains exactly the matching task identifier' do
            get_request
            xml = Nokogiri::XML(response.body)
            expect(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text)).to contain_exactly(matching_task.uuid)
            expect(xml.xpath('//dc:identifier', 'dc' => 'http://purl.org/dc/elements/1.1/').map(&:text)).to contain_exactly(matching_task.uuid)
          end
        end
      end

      context 'without time bounds' do
        it_behaves_like 'a successful OAI-PMH response'

        it 'contains all task identifiers' do
          get_request
          xml = Nokogiri::XML(response.body)
          expect(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text)).to match_array(tasks.map(&:uuid))
          expect(xml.xpath('//dc:identifier', 'dc' => 'http://purl.org/dc/elements/1.1/').map(&:text)).to match_array(tasks.map(&:uuid))
        end
      end

      context 'with time bounds' do
        let(:from) { Time.utc(2022).iso8601 }
        let(:until) { Time.utc(2024).iso8601 }

        it_behaves_like 'a successful OAI-PMH response'

        it 'contains exactly the matching task identifiers' do
          get_request
          xml = Nokogiri::XML(response.body)
          expect(xml.xpath('//xmlns:header//xmlns:identifier').map(&:text)).to contain_exactly(tasks.second.uuid)
          expect(xml.xpath('//dc:identifier', 'dc' => 'http://purl.org/dc/elements/1.1/').map(&:text)).to contain_exactly(tasks.second.uuid)
        end

        context 'with time bounds matching no record' do
          let(:from) { Time.utc(2100).iso8601 }

          it_behaves_like 'a valid OAI-PMH error', 'noRecordsMatch'
        end

        context 'with invalid time bounds' do
          let(:from) { Time.utc(2022).rfc822 }

          it_behaves_like 'a valid OAI-PMH error', 'badArgument'
        end
      end
    end

    context 'when verb is ListSets' do
      let(:verb) { 'ListSets' }

      let!(:labels) { create_list(:label, 5) }

      it_behaves_like 'a successful OAI-PMH response'

      it 'contains the names of all labels' do
        get_request
        xml = Nokogiri::XML(response.body)
        expect(xml.xpath('//xmlns:setName').map(&:text)).to match_array(labels.map(&:name).append('Label', 'Task'))
      end
    end

    context 'when verb is invalid' do
      let(:verb) { 'invalid' }

      it_behaves_like 'a valid OAI-PMH error', 'badVerb'
    end
  end
end
