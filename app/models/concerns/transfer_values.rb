# frozen_string_literal: true

module TransferValues
  # rubocop:disable Metrics/AbcSize
  def transfer_linked_files(other)
    files.each do |file|
      unless other.files.exists?(parent_id: file.id)
        files.delete(file)
      end
    end
    other.files.each do |file|
      if files.exists?(file.parent_id)
        old_file = files.find {|f| f.id == file.parent_id } # Required to force searching a copy in memory instead of db
        old_file.assign_attributes(file.attributes.except('id', 'parent_id', 'created_at', 'fileable_id'))
      else
        files.append(file.duplicate(set_parent_id: false))
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def transfer_contents(other)
    assign_attributes(other.attributes.except('id', 'parent_id', 'created_at'))
    transfer_linked_files(other)
  end

  def transfer_multiple(targets, others)
    # Remove deleted elements
    targets.each do |target|
      unless others.exists?(parent_id: target.id)
        targets.delete(target)
      end
    end
    # Adding new or modified elements
    others.each do |other|
      if targets.exists?(other.parent_id)
        targets.find {|target| target.id = other.parent_id }.transfer_contents other
      else
        targets.append(other.duplicate(set_parent_id: false))
      end
    end
    targets
  end
end
