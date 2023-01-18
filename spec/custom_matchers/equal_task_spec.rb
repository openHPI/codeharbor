# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'equal_task matcher' do
  let(:task) do
    build(:task,
      :with_content,
      programming_language:,
      files:,
      tests:,
      model_solutions:,
      uuid: SecureRandom.uuid)
  end
  let(:task2) do
    build(:task,
      :with_content,
      programming_language:,
      files: files2,
      tests: tests2,
      model_solutions: model_solutions2,
      uuid: SecureRandom.uuid)
  end

  let(:uuid) {}
  let(:programming_language) { build(:programming_language, :ruby) }
  let(:files) { [] }
  let(:files2) { [] }
  let(:model_solutions) { [] }
  let(:model_solutions2) { [] }
  let(:tests) { [] }
  let(:tests2) { [] }

  before do
    FactoryBot.rewind_sequences
    task
    FactoryBot.rewind_sequences
    task2
  end

  it 'successfully compares two similar tasks' do
    expect(task).to be_an_equal_task_as task2
  end

  context 'when different classes are submitted' do
    let(:string) { 'hello' }
    let(:integer) { 1234 }

    it 'fails' do
      expect(string).not_to be_an_equal_task_as integer
    end
  end

  context 'when one task is different' do
    let(:task2) { build(:task, title: 'different title') }

    it 'fails the comparison' do
      expect(task).not_to be_an_equal_task_as task2
    end
  end

  context 'when the tasks are complex' do
    let(:files) do
      [build(:task_file, :exportable), build(:task_file, :exportable)]
    end
    let(:files2) do
      [build(:task_file, :exportable), build(:task_file, :exportable)]
    end
    let(:tests) do
      [build(:test, :with_content, files: [build(:task_file, :exportable), build(:task_file, :exportable)])]
    end
    let(:tests2) do
      [build(:test, :with_content, files: [build(:task_file, :exportable), build(:task_file, :exportable)])]
    end
    let(:model_solutions) do
      [build(:model_solution, :with_content, files: [build(:task_file, :exportable), build(:task_file, :exportable)])]
    end
    let(:model_solutions2) do
      [build(:model_solution, :with_content, files: [build(:task_file, :exportable), build(:task_file, :exportable)])]
    end

    it 'successfully compares the tasks' do
      expect(task).to be_an_equal_task_as task2
    end

    context 'with a tiny change in a file' do
      before { task.files.first.content += 'a' }

      it 'fails' do
        expect(task).not_to be_an_equal_task_as task2
      end
    end

    context 'with a tiny change in a model_solution' do
      before { task.model_solutions.first.internal_description += 'a' }

      it 'fails' do
        expect(task).not_to be_an_equal_task_as task2
      end
    end

    context 'with a tiny change in a test' do
      before { task.tests.first.title += 'a' }

      it 'fails' do
        expect(task).not_to be_an_equal_task_as task2
      end
    end
  end

  context 'with two similar tasks' do
    let(:task) { build(:task, files:) }
    let(:task2) { build(:task, files: files2) }

    let(:files) { [build(:task_file, content: 'foo'), build(:task_file, content: 'bar'), build(:task_file, content: files_3_content)] }
    let(:files2) { [build(:task_file, content: 'foo'), build(:task_file, content: 'bar'), build(:task_file, content: files2_3_content)] }
    let(:files_3_content) { 'foobar' }
    let(:files2_3_content) { 'foobar' }

    it 'successfully compares the tasks' do
      expect(task).to be_an_equal_task_as task2
    end

    context 'when both tasks have two equal files, but are still different' do
      let(:files_3_content) { 'foo' }
      let(:files2_3_content) { 'bar' }

      it 'fails' do
        expect(task).not_to be_an_equal_task_as task2
      end
    end
  end
end
