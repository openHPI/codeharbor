# frozen_string_literal: true

module ParentValidation
  def parent_validation_check
    return if parent_id.nil?

    parent_entry = self.class.find_by(id: parent_id)
    if parent_entry.blank? || !parent_entry.task.parent_of?(task)
      errors.add(:parent_id, :invalid)
    end
  end
end
