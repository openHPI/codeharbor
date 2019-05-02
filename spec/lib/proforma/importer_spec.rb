# frozen_string_literal: true

require 'rails_helper'
require 'nokogiri'
require 'proforma/importer'
require 'proforma/xml_generator'
require 'proforma/zip_importer'

describe Proforma::Importer do
  let(:importer) { described_class.new }
  let(:generator) { Proforma::XmlGenerator.new }
  let(:exercise) { FactoryBot.create(:complex_exercise) }
  let(:xml) { generator.generate_xml(exercise) }
  let(:user) { FactoryBot.create(:user) }

  describe '#from_proforma_xml' do
    subject(:from_proforma_xml) { importer.from_proforma_xml(build(:exercise, :empty, user: user), doc) }

    let(:testing_framework) { FactoryBot.create(:junit_testing_framework, name: 'JUnit 4') }
    let(:license) { FactoryBot.create(:license, name: 'MIT License') }

    let(:doc) { Nokogiri::XML(xml) }

    # let(:imported_exercise) do
    #   imported_exercise = Exercise.new
    #   imported_exercise =
    #   # imported_exercise.user = user
    #   # imported_exercise.save
    #   imported_exercise
    # end

    it { is_expected.to be_valid }
    # it 'imports valid exercise' do
    #   expect(imported_exercise).to be_valid
    # end

    it 'has valid title' do
      expect(from_proforma_xml.title).to eq exercise.title
    end

    it 'has valid description' do
      expect(from_proforma_xml.descriptions.first.text).to eq exercise.descriptions.first.text
    end

    it 'has valid execution environment' do
      expect(from_proforma_xml.execution_environment_id).to eq exercise.execution_environment_id
    end

    context 'when it has a Main File' do
      before { from_proforma_xml.save }

      let(:file) { exercise.exercise_files.find_by(role: 'Main File') }
      let(:imported_file) { from_proforma_xml.exercise_files.find_by(role: 'Main File') }

      it 'is not nil' do
        expect(imported_file).not_to be_nil
      end

      it 'matches name of origin file' do
        expect(file.name).to eq imported_file.name
      end

      it 'matches content of origin file' do
        expect(file.content).to eq imported_file.content
      end
    end

    context 'when it has a Regular File' do
      before { from_proforma_xml.save }

      let(:file) { exercise.exercise_files.find_by(role: 'Regular File') }
      let(:imported_file) { from_proforma_xml.exercise_files.find_by(role: 'Regular File') }

      it 'is not nil' do
        expect(imported_file).not_to be_nil
      end

      it 'matches name of origin file' do
        expect(file.name).to eq imported_file.name
      end

      it 'matches content of origin file' do
        expect(file.content).to eq imported_file.content
      end
    end

    context 'when it has a Reference Implementation' do
      before { from_proforma_xml.save }

      let(:file) { exercise.exercise_files.find_by(role: 'Reference Implementation') }
      let(:imported_file) { from_proforma_xml.exercise_files.find_by(role: 'Reference Implementation') }

      it 'is not nil' do
        expect(imported_file).not_to be_nil
      end

      it 'matches name of origin file' do
        expect(file.name).to eq imported_file.name
      end

      it 'matches content of origin file' do
        expect(file.content).to eq imported_file.content
      end
    end

    context 'when it has no user defined test-file' do
      let(:imported_file) { from_proforma_xml.exercise_files.find_by(role: 'User-defined Test') }

      it 'does not have a user defined test-file' do
        expect(imported_file).to be_nil
      end
    end

    context 'when it has a valid test-file' do
      let(:file) { exercise.tests.first }
      let(:imported_file) { from_proforma_xml.tests.first }

      it 'is not nil' do
        expect(imported_file).not_to be_nil
      end

      it 'matches name of origin file' do
        expect(file.name).to eq imported_file.name
      end

      it 'matches content of origin file' do
        expect(file.content).to eq imported_file.content
      end
    end
  end
end
