class Test < ActiveRecord::Base
  belongs_to :testing_framework
  belongs_to :exercise
  belongs_to :exercise_file

  def content
    if exercise_file
      return exercise_file.content
    else
      return ''
    end
  end

  def name
    if exercise_file
      return exercise_file.name
    else
      return ''
    end
  end

  def path
    if exercise_file
      return exercise_file.path
    else
      return ''
    end
  end

  def file_type_id
    if exercise_file
      return exercise_file.file_type_id
    else
      return ''
    end
  end

  def file_type
    if exercise_file
      return exercise_file.file_type
    else
      return ''
    end
  end

end
