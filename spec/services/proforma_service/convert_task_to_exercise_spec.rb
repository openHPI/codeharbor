# frozen_string_literal: true

require 'rails_helper'

xdescribe ProformaService::ConvertTaskToExercise do
  describe '.new' do
    subject(:convert_to_exercise_service) { described_class.new(task: task, user: user, exercise: exercise) }

    let(:task) { Proforma::Task.new }
    let(:user) { build(:user) }
    let(:exercise) { build(:exercise) }

    it 'assigns task' do
      expect(convert_to_exercise_service.instance_variable_get(:@task)).to be task
    end

    it 'assigns user' do
      expect(convert_to_exercise_service.instance_variable_get(:@user)).to be user
    end

    it 'assigns exercise' do
      expect(convert_to_exercise_service.instance_variable_get(:@exercise)).to be exercise
    end
  end

  describe '#execute' do
    subject(:convert_to_exercise_service) { described_class.call(task: task, user: user, exercise: exercise) }

    before { FileType.create(file_extension: '.txt') }

    let(:task) do
      Proforma::Task.new(
        title: 'title',
        description: description,
        internal_description: 'internal_description',
        proglang: {name: 'proglang-name', version: 'proglang-version'},
        uuid: 'uuid',
        parent_uuid: 'parent_uuid',
        language: 'language',
        model_solutions: model_solutions,
        files: files,
        tests: tests
      )
    end
    let(:description) { 'description' }
    let(:user) { build(:user) }
    let(:files) { [] }
    let(:tests) { [] }
    let(:model_solutions) { [] }
    let(:exercise) {}

    it 'creates an exercise with the correct attributes' do
      expect(convert_to_exercise_service).to have_attributes(
        title: 'title',
        descriptions: have(1).item.and(include(have_attributes(text: 'description',
                                                               primary: true,
                                                               language: 'language'))),
        instruction: 'internal_description',
        execution_environment: be_an(ExecutionEnvironment).and(have_attributes(language: 'proglang-name', version: 'proglang-version')),
        uuid: be_blank,
        private: true,
        user: user,
        license: be_nil,
        exercise_files: be_empty,
        tests: be_empty,
        state_list: ['new']
      )
    end

    context 'when description contains html' do
      let(:description) { '<p>description</p>' }

      it 'creates an exercise with a correct description' do
        expect(convert_to_exercise_service).to have_attributes(
          descriptions: include(have_attributes(text: 'description'))
        )
      end

      context 'with a html entity' do
        let(:description) { '<p>descr&uuml;ption</p>' }

        it 'creates an exercise with a correct description' do
          expect(convert_to_exercise_service).to have_attributes(
            descriptions: include(have_attributes(text: 'descrüption'))
          )
        end
      end
    end

    context 'when task has a file' do
      let(:files) { [file] }
      let(:file) do
        Proforma::TaskFile.new(
          id: 'id',
          content: content,
          filename: 'filename.txt',
          used_by_grader: 'used_by_grader',
          visible: visible,
          usage_by_lms: usage_by_lms,
          binary: binary,
          internal_description: 'internal_description',
          mimetype: mimetype
        )
      end
      let(:usage_by_lms) { 'display' }
      let(:mimetype) { 'mimetype' }
      let(:binary) { false }
      let(:content) { 'content' }
      let(:visible) { 'yes' }

      it 'creates an exercise with a file that has the correct attributes' do
        expect(convert_to_exercise_service.exercise_files.first).to have_attributes(
          content: 'content',
          name: 'filename',
          role: 'internal_description',
          hidden: false,
          read_only: true,
          file_type: be_a(FileType).and(have_attributes(file_extension: '.txt'))
        )
      end

      it 'creates a new Exercise on save' do
        expect { convert_to_exercise_service.save }.to change(Exercise, :count).by(1)
      end

      context 'when visible is no' do
        let(:visible) { 'no' }

        it 'creates an exercise with a hidden file' do
          expect(convert_to_exercise_service.exercise_files.first).to have_attributes(hidden: true)
        end
      end

      context 'when visible is delayed' do
        let(:visible) { 'delayed' }

        it 'creates an exercise with a hidden file' do
          expect(convert_to_exercise_service.exercise_files.first).to have_attributes(hidden: true)
        end
      end

      context 'when file is very large' do
        let(:content) { 'test' * 10**5 }

        it 'creates an exercise with a file that has the correct attributes' do
          expect(convert_to_exercise_service.exercise_files.first).to have_attributes(content: content)
        end
      end

      context 'when file is binary' do
        let(:mimetype) { 'image/png' }
        let(:binary) { true }

        it 'creates an exercise with an exercise_file with has the file attached' do
          expect(convert_to_exercise_service.exercise_files.first.attachment).to be_attached
        end
      end

      context 'when usage_by_lms is edit' do
        let(:usage_by_lms) { 'edit' }

        it 'creates an exercise with a file with correct attributes' do
          expect(convert_to_exercise_service.exercise_files.first).to have_attributes(read_only: false)
        end
      end

      context 'when file is a model-solution-placeholder (needed by proforma until issue #5 is resolved)' do
        let(:file) { Proforma::TaskFile.new(id: 'ms-placeholder-file') }

        it 'leaves exercise_files empty' do
          expect(convert_to_exercise_service.exercise_files).to be_empty
        end
      end
    end

    context 'when task has a model-solution' do
      let(:model_solutions) { [model_solution] }
      let(:model_solution) do
        Proforma::ModelSolution.new(
          id: 'ms-id',
          files: ms_files
        )
      end
      let(:ms_files) { [ms_file] }
      let(:ms_file) do
        Proforma::TaskFile.new(
          id: 'ms-file',
          content: 'content',
          filename: 'filename.txt',
          used_by_grader: 'used_by_grader',
          visible: 'yes',
          usage_by_lms: 'display',
          binary: false
        )
      end

      it 'creates an exercise with a file with role Reference Implementation' do
        expect(convert_to_exercise_service.exercise_files.first).to have_attributes(
          role: 'reference_implementation'
        )
      end

      context 'when task has two model-solutions' do
        let(:model_solutions) { [model_solution, model_solution2] }
        let(:model_solution2) do
          Proforma::ModelSolution.new(
            id: 'ms-id-2',
            files: ms_files2
          )
        end
        let(:ms_files2) { [ms_file2] }
        let(:ms_file2) do
          Proforma::TaskFile.new(
            id: 'ms-file-2',
            content: 'content',
            filename: 'filename.txt',
            used_by_grader: 'used_by_grader',
            visible: 'yes',
            usage_by_lms: 'display',
            binary: false
          )
        end

        it 'creates an exercise with two files with role Reference Implementation' do
          expect(convert_to_exercise_service.exercise_files).to have(2).items.and(all(have_attributes(role: 'reference_implementation')))
        end
      end
    end

    context 'when task has a test' do
      let(:tests) { [test] }
      let(:test) do
        Proforma::Test.new(
          id: 'test-id',
          title: 'title',
          description: 'description',
          internal_description: 'internal_description',
          test_type: 'test_type',
          files: test_files,
          configuration: configuration,
          meta_data: {
            'feedback-message' => 'feedback-message',
            'testing-framework' => 'testing-framework',
            'testing-framework-version' => 'testing-framework-version'
          }
        )
      end

      let(:configuration) {}
      let(:test_files) { [test_file] }
      let(:test_file) do
        Proforma::TaskFile.new(
          id: 'test_file_id',
          content: 'testfile-content',
          filename: 'testfile.txt',
          used_by_grader: 'yes',
          visible: 'no',
          usage_by_lms: 'display',
          binary: false,
          internal_description: 'teacher_defined_test'
        )
      end

      it 'creates an exercise with a test' do
        expect(convert_to_exercise_service.tests).to have(1).item
      end

      it 'creates an exercise with a test with correct attributes' do
        expect(convert_to_exercise_service.tests.first).to have_attributes(
          feedback_message: 'feedback-message',
          testing_framework: have_attributes(
            name: 'testing-framework',
            version: 'testing-framework-version'
          ),

          exercise_file: have_attributes(
            content: 'testfile-content',
            name: 'testfile',
            role: 'teacher_defined_test',
            hidden: true,
            read_only: true,
            file_type: be_a(FileType).and(have_attributes(file_extension: '.txt')),
            purpose: 'test'
          )
        )
      end

      context 'when test has unittest configuration' do
        let(:configuration) { {'version' => '1.23', 'framework' => 'rspec', 'entry-point' => entry_point} }
        let(:entry_point) { test_file.filename }

        it 'uses test_file as main-file for the test' do
          expect(convert_to_exercise_service.tests.first).to have_attributes content: test_file.content
        end

        context 'when entry_point does not refer to included file' do
          let(:entry_point) { 'something_else.rb' }

          it 'ignores entry_point and uses test_file as main-file for the test' do
            expect(convert_to_exercise_service.tests.first).to have_attributes content: test_file.content
          end
        end
      end

      context 'when test has no meta_data' do
        let(:test) do
          Proforma::Test.new(
            id: 'test-id',
            title: 'title',
            description: 'description',
            internal_description: 'internal_description',
            test_type: 'test_type',
            files: test_files
          )
        end

        it 'creates an exercise with a test' do
          expect(convert_to_exercise_service.tests).to have(1).item
        end

        it 'creates an exercise with a test with correct attributes' do
          expect(convert_to_exercise_service.tests.first).to have_attributes(
            exercise_file: have_attributes(
              content: 'testfile-content',
              name: 'testfile',
              role: 'teacher_defined_test',
              hidden: true,
              read_only: true,
              file_type: be_a(FileType).and(have_attributes(file_extension: '.txt')),
              purpose: 'test'
            )
          )
        end
      end

      context 'when test has no files' do
        let(:test_files) { [] }

        it 'creates an exercise without a test' do
          expect(convert_to_exercise_service.tests).to have(0).item
        end
      end

      context 'when test has multiple files' do
        let(:test_files) { [test_file, test_file2] }
        let(:test_file2) do
          Proforma::TaskFile.new(
            id: 'test_file2_id',
            content: 'testfile2-content',
            filename: 'testfile2.txt',
            used_by_grader: 'yes',
            visible: 'no',
            usage_by_lms: 'display',
            binary: false,
            internal_description: 'teacher_defined_test'
          )
        end

        it 'creates an exercise with a test' do
          expect(convert_to_exercise_service.tests).to have(1).item
        end

        it 'uses test_file as main-file for the test' do
          expect(convert_to_exercise_service.tests.first).to have_attributes content: test_file.content
        end

        it 'creates an exercise_file for the remaining task_file (test_file2) and sets hidden' do
          expect(convert_to_exercise_service.exercise_files.first).to have_attributes content: test_file2.content
        end

        context 'when test_file is visible' do
          before { test_file2.visible = 'yes' }

          it 'creates a hidden exercise_file' do
            expect(convert_to_exercise_service.exercise_files.first).to have_attributes hidden: true
          end
        end

        context 'when test has unittest configuration' do
          let(:configuration) { {'version' => '1.23', 'framework' => 'rspec', 'entry-point' => test_file2.filename} }

          it 'uses test_file2 as main-file for the test' do
            expect(convert_to_exercise_service.tests.first).to have_attributes content: test_file2.content
          end

          it 'creates an exercise_file for the remaining task_file (test_file)' do
            expect(convert_to_exercise_service.exercise_files.first).to have_attributes content: test_file.content
          end
        end
      end

      context 'when task has multiple tests' do
        let(:tests) { [test, test2] }
        let(:test2) do
          Proforma::Test.new(
            files: test_files2,
            meta_data: {
              'feedback-message' => 'feedback-message',
              'testing-framework' => 'testing-framework',
              'testing-framework-version' => 'testing-framework-version'
            }
          )
        end
        let(:test_files2) { [test_file2] }
        let(:test_file2) do
          Proforma::TaskFile.new(
            id: 'test_file_id2',
            content: 'testfile-content',
            filename: 'testfile.txt',
            used_by_grader: 'yes',
            visible: 'no',
            usage_by_lms: 'display',
            binary: false,
            internal_description: 'teacher_defined_test'
          )
        end

        it 'creates an exercise with two test' do
          expect(convert_to_exercise_service.tests).to have(2).items
        end
      end
    end

    context 'when exercise is set' do
      let(:exercise) do
        create(
          :exercise_with_single_java_main_file,
          title: 'exercise-title',
          descriptions: [build(:description, :primary, text: 'exercise-description')],
          instruction: 'exercise-instruction'
        )
      end

      before { exercise.reload }

      it 'assigns all values to given exercise' do
        convert_to_exercise_service.save
        expect(exercise.reload).to have_attributes(
          id: exercise.id,
          title: task.title,
          descriptions: include(
            have_attributes(primary: true, text: Kramdown::Document.new(task.description, html_to_native: true).to_kramdown.strip)
          ),
          instruction: task.internal_description,
          execution_environment: have_attributes(language: task.proglang[:name], version: task.proglang[:version]),
          uuid: exercise.uuid,
          private: true,
          user: exercise.user,
          license: exercise.license,
          exercise_files: be_empty,
          tests: be_empty,
          state_list: ['updated']
        )
      end

      it 'does not create a new Exercise on save' do
        expect { convert_to_exercise_service.save }.not_to change(Exercise, :count)
      end

      context 'with file, model solution and test' do
        let(:files) { [file] }
        let(:file) do
          Proforma::TaskFile.new(
            id: 'id',
            content: 'content',
            filename: 'filename.txt',
            used_by_grader: 'used_by_grader',
            visible: 'yes',
            usage_by_lms: 'display',
            binary: false,
            internal_description: 'internal_description'
          )
        end
        let(:tests) { [test] }
        let(:test) do
          Proforma::Test.new(
            id: 'test-id',
            title: 'title',
            description: 'description',
            internal_description: 'internal_description',
            test_type: 'test_type',
            files: test_files,
            meta_data: {
              'feedback-message' => 'feedback-message',
              'testing-framework' => 'testing-framework',
              'testing-framework-version' => 'testing-framework-version'
            }
          )
        end
        let(:test_files) { [test_file] }
        let(:test_file) do
          Proforma::TaskFile.new(
            id: 'test_file_id',
            content: 'testfile-content',
            filename: 'testfile.txt',
            used_by_grader: 'yes',
            visible: 'no',
            usage_by_lms: 'display',
            binary: false,
            internal_description: 'teacher_defined_test'
          )
        end
        let(:model_solutions) { [model_solution] }
        let(:model_solution) do
          Proforma::ModelSolution.new(
            id: 'ms-id',
            files: ms_files
          )
        end
        let(:ms_files) { [ms_file] }
        let(:ms_file) do
          Proforma::TaskFile.new(
            id: 'ms-file',
            content: 'ms-content',
            filename: 'filename.txt',
            used_by_grader: 'used_by_grader',
            visible: 'yes',
            usage_by_lms: 'display',
            binary: false,
            internal_description: 'reference_implementation'
          )
        end

        it 'assigns all values to given exercise' do
          expect(convert_to_exercise_service).to have_attributes(
            id: exercise.id,
            exercise_files: have(2).items.and(include(have_attributes(content: 'ms-content', role: 'reference_implementation')))
              .and(include(have_attributes(content: 'content', role: 'internal_description'))),
            tests: have(1).item
              .and(include(have_attributes(exercise_file: have_attributes(content: 'testfile-content', role: 'teacher_defined_test'))))
          )
        end
      end
    end
  end
end
