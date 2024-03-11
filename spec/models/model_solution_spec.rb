# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelSolution do
  describe 'validations' do
    it { is_expected.to belong_to(:task) }
    it { is_expected.to validate_presence_of(:xml_id) }
    it { is_expected.to validate_uniqueness_of(:xml_id).scoped_to(:task_id) }

    it_behaves_like 'parent validation with parent_id', :model_solution
  end

  describe '#duplicate' do
    subject(:duplicate) { model_solution.duplicate }

    let(:model_solution) do
      create(:model_solution, task: create(:task), files: [build(:task_file, :exportable), build(:task_file, :exportable)])
    end

    it 'creates a new model_solution' do
      expect(duplicate).not_to be model_solution
    end

    it 'has the same attributes' do
      expect(duplicate).to have_attributes(model_solution.attributes.except('created_at', 'updated_at', 'id', 'fileable_id', 'parent_id'))
    end

    it 'creates new files' do
      expect(duplicate.files).not_to match_array model_solution.files
    end

    it 'creates new files with the same attributes' do
      expect(duplicate.files).to match_array(model_solution.files.map do |file|
                                               have_attributes(file.attributes.except('created_at', 'updated_at', 'id', 'fileable_id', 'parent_id'))
                                             end)
    end
  end

  describe '#transfer_multiple_entities' do
    it_behaves_like 'transfer multiple entities', :model_solution
    it_behaves_like 'transfer files', :model_solution
  end
end
