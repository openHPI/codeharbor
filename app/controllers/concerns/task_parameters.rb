# frozen_string_literal: true

module TaskParameters
  private

  def file_params
    %i[id content attachment path name internal_description mime_type use_attached_file used_by_grader visible usage_by_lms xml_id _destroy
       parent_id parent_blob_id]
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
      model_solutions_attributes: model_solution_params, label_names: []).tap {|parameters| fix_nested_files_params(parameters) }
  end

  def group_tasks_params
    params.require(:group_tasks).permit(group_ids: [])
  end

  def import_confirm_params
    params.permit(:import_id, :subfile_id, :import_type)
  end

  def fix_nested_files_params(parameters)
    # The task_params might contain incomplete attributes for files, which we must fix before using the parameters.
    # Those file attributes can be attached directly to the task, to any of test or to any model solution.
    # For each of the potential file attributes, we must check if the attachment attribute should present and re-add it if missing.
    # This behavior is needed, since SimpleForm does not keep the (empty) attachment attribute if no file got attached by the user.
    # Otherwise, an old file version would be linked to the task, test or model solution after a failed model validation.
    # When this happens, the old file content is used alongside the name of the new file, which is confusing for the user.

    # Fix file attributes directly linked to the task.
    fix_attachment_params(parameters)

    # Fix file attributes linked to tests. The tests are stored in a hash with the test number as the key.
    parameters[:tests_attributes]&.each_value {|test_parameters| fix_attachment_params(test_parameters) }

    # Fix file attributes linked to model solutions. The model solutions are stored in a hash with the model solution number as the key.
    parameters[:model_solutions_attributes]&.each_value {|model_solution_parameters| fix_attachment_params(model_solution_parameters) }
  end

  def fix_attachment_params(parameters)
    # Files are stored in a hash with the file number as the key.
    parameters[:files_attributes]&.each_value do |file|
      # Do not modify the given file attributes if an attachment key is already present.
      # This is needed to keep the attachment if the user sent a file.
      next if file.key?(:attachment)
      # Do not modify the given file attributes if the parent_blob_id is present.
      # This ensures that an attachment is kept even if the user did not send a file.
      # For example, a file has been stored previously and the user only wants to update unrelated attributes.
      # As soon as the user chose a file manually and validations fail, the parent_blob_id is left empty.
      # Then, on a second try, the (updated) file is no longer linked to the previous file version.
      next if file[:parent_blob_id].present?

      # If none of the above conditions is met, the user did not send a file despite previously making changes.
      # In this case, we must re-add the attachment attribute and set it to `nil` to indicate the missing file.
      file[:attachment] = nil
    end
  end
end
