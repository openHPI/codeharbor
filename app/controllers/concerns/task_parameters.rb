# frozen_string_literal: true

module TaskParameters
  private

  def file_params
    %i[id content attachment path name internal_description mime_type use_attached_file used_by_grader visible usage_by_lms xml_id _destroy
       parent_id]
  end

  def test_params
    [:id, :title, :testing_framework_id, :description, :internal_description, :test_type, :xml_id, :validity, :timeout, :_destroy,
     :parent_id, {files_attributes: file_params}]
  end

  def model_solution_params
    [:id, :description, :internal_description, :xml_id, :_destroy, :parent_id, {files_attributes: file_params}]
  end

  def task_params
    params.require(:task).permit(:title, :description, :internal_description, :parent_uuid, :language, :license_id,
      :programming_language_id, :access_level, files_attributes: file_params, tests_attributes: test_params,
      model_solutions_attributes: model_solution_params, label_names: [])
  end

  def group_tasks_params
    params.permit(group_tasks: {group_ids: []})[:group_tasks]
  end

  def import_confirm_params
    params.permit(:import_id, :subfile_id, :import_type)
  end
end
