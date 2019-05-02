# frozen_string_literal: true

module ExercisesHelper
  def fa_with_slash(classes)
    render('exercises/fa_with_slash', classes: classes)
  end

  def block_to_partial(partial_name, options = {}, &block)
    options[:body] = capture(&block)
    concat(render(partial: partial_name, locals: options), block.binding)
  end
end
