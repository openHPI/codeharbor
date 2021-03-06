# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExerciseService::CheckExternal do
  describe '.new' do
    subject(:export_service) { described_class.new(uuid: uuid, account_link: account_link) }

    let(:uuid) { SecureRandom.uuid }
    let(:account_link) { build(:account_link) }

    it 'assigns uuid' do
      expect(export_service.instance_variable_get(:@uuid)).to be uuid
    end

    it 'assigns account_link' do
      expect(export_service.instance_variable_get(:@account_link)).to be account_link
    end
  end

  describe '#execute' do
    subject(:check_external_service) { described_class.call(uuid: uuid, account_link: account_link) }

    let(:uuid) { SecureRandom.uuid }
    let(:account_link) { build(:account_link) }
    let(:response) { {}.to_json }

    before { stub_request(:post, account_link.check_uuid_url).to_return(body: response) }

    it 'calls the correct url' do
      expect(check_external_service).to have_requested(:post, account_link.check_uuid_url)
    end

    it 'submits the correct headers' do
      expect(check_external_service).to have_requested(:post, account_link.check_uuid_url)
        .with(headers: {content_type: 'application/json', authorization: "Bearer #{account_link.api_key}"})
    end

    it 'submits the correct body' do
      expect(check_external_service).to have_requested(:post, account_link.check_uuid_url)
        .with(body: {uuid: uuid}.to_json)
    end

    context 'when response contains a JSON with expected keys' do
      let(:response) { {exercise_found: true, update_right: true}.to_json }

      it 'returns the correct hash' do
        expect(check_external_service).to eql(error: false, message: I18n.t('exercises.export_exercise.check.exercise_found'),
                                              exercise_found: true, update_right: true)
      end

      context 'with exercise_found: false and no update_right' do
        let(:response) { {exercise_found: false}.to_json }

        it 'returns the correct hash' do
          expect(check_external_service).to eql(error: false, message: I18n.t('exercises.export_exercise.check.no_exercise'),
                                                exercise_found: false)
        end
      end

      context 'with exercise_found: true and update_right: false' do
        let(:response) { {exercise_found: true, update_right: false}.to_json }

        it 'returns the correct hash' do
          expect(check_external_service).to eql(error: false, message: I18n.t('exercises.export_exercise.check.exercise_found_no_right'),
                                                exercise_found: true, update_right: false)
        end
      end
    end

    context 'when response does not contain JSON' do
      let(:response) { 'foo' }

      it 'returns the correct hash' do
        expect(check_external_service).to eql(error: true, message: I18n.t('exercises.export_exercise.error'))
      end
    end

    context 'when the request fails' do
      before { allow(Faraday).to receive(:new).and_raise(Faraday::Error, 'error') }

      it 'returns the correct hash' do
        expect(check_external_service).to eql(error: true, message: I18n.t('exercises.export_exercise.error'))
      end
    end
  end
end
