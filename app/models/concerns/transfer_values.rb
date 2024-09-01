# frozen_string_literal: true

module TransferValues
  def excluded_attributes(entity_type)
    exclude = %w[id parent_id created_at task_id]
    if entity_type == 'task_file'
      exclude.append('fileable_id', 'fileable_type')
    else
      exclude.append('xml_id')
    end
    exclude
  end

  def transfer_attributes(other, excluded_attributes = [])
    assign_attributes(other.attributes.except(*excluded_attributes))
    if is_a?(TaskFile) && other.attachment.attached?
      attachment.attach(other.attachment.blob)
      self.use_attached_file = 'true'
    elsif !is_a?(TaskFile)
      transfer_multiple_entities(files, other.files, 'task_file')
    end
  end

  def transfer_multiple_entities(targets, others, entity_type) # rubocop:disable Metrics/AbcSize
    # Remove deleted elements
    targets.each do |target|
      unless others.exists?(parent_id: target.id)
        targets.delete(target)
      end
    end
    # Adding new or modified elements
    others.to_a.each do |other|
      if targets.exists?(other.parent_id)
        old_entity = targets.find {|target| target.id == other.parent_id } # Required to force searching a copy in memory instead of db
        old_entity.transfer_attributes(other, excluded_attributes(entity_type))
      else
        targets.append(other.duplicate(set_parent_id: false))
      end
    end
  end
end
