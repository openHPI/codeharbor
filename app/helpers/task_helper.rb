# frozen_string_literal: true

module TaskHelper
  def contrib_task_params
    params.require(:task).permit(:title, :description, :internal_description, :language,
      :programming_language_id, files_attributes: file_params, tests_attributes: test_params,
      model_solutions_attributes: model_solution_params, label_ids: [])
  end
end
