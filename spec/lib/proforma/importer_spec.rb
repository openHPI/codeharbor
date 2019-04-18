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

  describe 'import exercise' do
    let(:testing_framework) { FactoryBot.create(:junit_testing_framework, name: 'JUnit 4') }
    let(:license) { FactoryBot.create(:license, name: 'MIT License') }

    let(:imported_exercise) do
      imported_exercise = Exercise.new
      doc = Nokogiri::XML(xml)
      imported_exercise = importer.from_proforma_xml(imported_exercise, doc)
      imported_exercise.user = user
      imported_exercise.save
      imported_exercise
    end

    it 'imports valid exercise' do
      expect(imported_exercise).to be_valid
    end

    it 'has valid title' do
      expect(imported_exercise.title).to eq exercise.title
    end

    it 'has valid description' do
      expect(imported_exercise.descriptions.first.text).to eq exercise.descriptions.first.text
    end

    it 'has valid execution environment' do
      expect(imported_exercise.execution_environment_id).to eq exercise.execution_environment_id
    end

    describe 'files' do
      it 'has valid main file' do
        file = exercise.exercise_files.find_by(role: 'Main File')
        imported_file = imported_exercise.exercise_files.find_by(role: 'Main File')
        expect(imported_file).not_to be_nil
        expect(file.name).to eq imported_file.name
        expect(file.content).to eq imported_file.content
      end

      it 'has valid regular file' do
        file = exercise.exercise_files.find_by(role: 'Regular File')
        imported_file = imported_exercise.exercise_files.find_by(name: 'explanation')
        expect(imported_file).not_to be_nil
        expect(file.name).to eq imported_file.name
        expect(file.content).to eq imported_file.content
      end

      it 'has valid solution file' do
        file = exercise.exercise_files.find_by(role: 'Reference Implementation')
        imported_file = imported_exercise.exercise_files.find_by(role: 'Reference Implementation')
        expect(imported_file).not_to be_nil
        expect(file.name).to eq imported_file.name
        expect(file.content).to eq imported_file.content
      end

      it 'does not have a user defined test-file' do
        imported_file = imported_exercise.exercise_files.find_by(role: 'User-defined Test')
        expect(imported_file).to be_nil
      end

      it 'has valid test file' do
        file = exercise.tests.first
        imported_file = imported_exercise.tests.first
        expect(imported_file).not_to be_nil
        expect(file.name).to eq imported_file.name
        expect(file.content).to eq imported_file.content
      end
    end
  end
end
