class FixExerciseFileTestRelationship < ActiveRecord::Migration[6.0]
  def change
    add_reference :exercise_files, :test, index: true
    remove_index :tests, name: :index_tests_on_exercise_file_id, column: :exercise_file_id #TODO TEMP

    exercise_file_ids = Test.all.map(&:exercise_file_id)

    # find exercise_files that are referenced from multiple tests
    duplicates = exercise_file_ids.select{ |e| exercise_file_ids.count(e) > 1 }.uniq

    duplicates.each do |exercise_file_id|
      tests_with_duplicates = Test.where(exercise_file_id: exercise_file_id).drop(1)
      tests_with_duplicates.each do |test|
        # create new ExerciseFile do be referenced, instead of the duplicate
        new_exercise_file = ExerciseFile.find(test.exercise_file_id).duplicate
        new_exercise_file.save!(validate: false)
        test.update(exercise_file_id: new_exercise_file.id)
      end
    end

    # normal case: reverse reference.
    Test.all.each do |test|
      ExerciseFile.find(test.exercise_file_id).update(test_id: test.id)
    end

    remove_column :tests, :exercise_file_id
  end
end
