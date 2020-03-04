class FixExerciseFileTestRelationship < ActiveRecord::Migration[6.0]
  def change
    add_reference :exercise_files, :test, index: true
    remove_index :tests, name: :index_tests_on_exercise_file_id, column: :exercise_file_id #TODO TEMP

    exercise_file_ids=Test.all.map(&:exercise_file_id)
    duplicates = exercise_file_ids.select{ |e| exercise_file_ids.count(e) > 1 }.uniq

    duplicates.each do |efid|
      tests_with_duplicates =  Test.where(exercise_file_id: efid).drop(1)
      tests_with_duplicates.each do |test|
        new_exercise_file = ExerciseFile.find(test.exercise_file_id).duplicate
        new_exercise_file.save!
        test.update(exercise_file_id: new_exercise_file.id)
      end
    end

    Test.all.each do |test|
      ExerciseFile.find(test.exercise_file_id).update(test_id: test.id)
    end

    # remove_column :tests, :exercise_file_id
  end
end
# last id => 2587
# test=Test.all.select{|t|ExerciseFile.find(t.exercise_file_id).test_id != t.id }
