# frozen_string_literal: true

module TransferValues
  def transfer_linked_files(other)
    other.files.each do |file|
      if files.exists?(file.parent_id)
        old_file = files.find(file.parent_id)
        old_file.assign_attributes(file.attributes.except('id', 'parent_id', 'created_date', 'fileable_id'))
      else
        temp_file = TaskFile.new(file.attributes.except('id').merge(fileable_id: id))
        files.append(temp_file)
      end
    end
    files.each do |file|
      unless other.files.exists?(parent_id: file.id)
        files.delete(file)
      end
    end
  end

  def transfer_contents(other)
    assign_attributes(other.attributes.except('id', 'parent_id', 'created_date'))
    transfer_linked_files(other)
  end

  def transfer_multiple(ours, others, parent)
    others.each do |other|
      if ours.exists?(other.id)
        ours.find(other.id).transfer_contents
      else
        ours.append(other.class.name.constantize.new(other.attributes.except('id').merge(parent)))
      end
    end
    ours.each do |our|
      unless others.exists?(parent_id: our.id)
        ours.delete(our)
      end
    end
    ours
  end
end
