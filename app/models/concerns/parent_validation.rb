# frozen_string_literal: true

module ParentValidation
  def validate_file_parent_ids
    org_ids = []
    own_ids = []
    if instance_of?(Task)
      parent_entry = parent
    else
      return if parent_id.nil?

      parent_entry = self.class.find(parent_id)
    end
    return if parent_entry.nil?

    parent_entry.files.each do |file|
      org_ids.append(file.id)
    end
    files.each do |file|
      if own_ids.include?(file.parent_id)
        errors.add(:parent_id, :duplicate)
      else
        own_ids.append(file.parent_id)
      end
      unless org_ids.include?(file.parent_id)
        errors.add(:parent_id, :invalid)
      end
    end
  end
end
