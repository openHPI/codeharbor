# frozen_string_literal: true

module ParentValidation
  def parent_validation_check
    if parent_id.nil?
     return
    end

    parent_entry = self.class.find(parent_id)
    if parent_entry.blank?
      errors.add(:parent_id, :invalid)
    end
    unless parent_entry.task.parent_of?(task)
      errors.add(:parent_id, :invalid)
    end
  end
end
