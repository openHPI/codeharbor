class RemoveReportReferenceFromExercise < ActiveRecord::Migration
  def change
    remove_reference :exercises, :report, index: true, foreign_key: true
  end
end
