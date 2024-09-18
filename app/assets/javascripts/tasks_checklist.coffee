MIN_TITLE_CHARS = 1
MIN_DESCRIPTION_WORDS = 30
MIN_LABELS = 2

todos = ['title', 'programming_language', 'description', 'language', 'labels', 'license', 'file', 'test', 'model_solution']

initialize_checklist = ->
  if $('.completeness-checklist-container').length == 0
    return

  initialize_callbacks()
  set_progress(0)
  update_checklist()

  $('.maximized-checklist').on 'click', -> minimize_checklist()
  $('.minimized-checklist').on 'click', -> maximize_checklist()


maximize_checklist = ->
  if $('.maximized-checklist').hasClass('d-none')
    toggle_checklist(200, 400)

minimize_checklist = ->
  if $('.minimized-checklist').hasClass('d-none')
    toggle_checklist(400, 200)

toggle_checklist = (closing_duration, opening_duration) ->
  $('.checklist-content').animate({width: [ "toggle", "swing" ]}, closing_duration, () ->
    $(this).find('.maximized-checklist, .minimized-checklist').toggleClass('d-none');
    $('.checklist-content').animate({width: [ "toggle", "swing" ]}, opening_duration)
  )


click_handler = ->
  setTimeout -> # trick to execute after all other handlers (after new nested file has been created)
    update_checklist()
    $('.btn.toggle-input, .btn.remove_nested_fields_link').off 'click', (_) -> setTimeout update_checklist, 0
    $('.btn.toggle-input, .btn.remove_nested_fields_link').on 'click', (_) -> setTimeout update_checklist, 0
    $('.add_nested_fields_link').off 'click', click_handler
    $('.add_nested_fields_link').on 'click', click_handler
  , 0

initialize_callbacks = ->
  $('body').on 'change', (_) -> update_checklist()
  $('.add_nested_fields_link').on 'click', click_handler
  $('.btn.toggle-input, .btn.remove_nested_fields_link').on 'click', (_) -> setTimeout update_checklist, 0


check = (todo_name) ->
  switch
    when todo_name == 'title' then $('#task_title').val().length >= MIN_TITLE_CHARS
    when todo_name == 'programming_language' then $('#task_programming_language_id').val().length > 0
    when todo_name == 'description' then $('#markdown-input-description').val().trim().split(/\s+/).length > MIN_DESCRIPTION_WORDS
    when todo_name == 'language' then $('#task_language').val().length > 0
    when todo_name == 'labels' then $('#task_label_names').val().length >= MIN_LABELS
    when todo_name == 'license' then $('#task_license_id').val().length > 0
    when todo_name == 'file' then check_files($('fieldset.nested_task_files'))
    when todo_name == 'test' then check_tests()
    when todo_name == 'model_solution' then check_model_solutions()
    else console.error("Unknown todo_name #{todo_name}")


check_files = (files) ->
  ok = false

  files.each (index, file) ->
    if $(file).css('display') != 'none'

      name_present = $(file).find('.file-name').val().length > 0
      content_present = $(file).find('.file-content').val().length > 0
      attachment_present = $(file).find('.file-attachment').val().length > 0 || $(file).find('.attachment_present').length > 0
      use_attachment = $(file).find('.use-attached-file').val() == "true"

      attachment_or_content_present = (use_attachment && attachment_present) || (!use_attachment && content_present)

      if name_present && attachment_or_content_present
        ok = true
  return ok


check_tests = ->
  ok = false

  $('fieldset.nested_task_tests').each (index, nested_task_test) ->
    if $(nested_task_test).css('display') != 'none'
      title_present = $(nested_task_test).find('.test-title').val().length > 0
      file_present = check_files($(nested_task_test).find('fieldset.nested_fields'))

      if title_present && file_present
        ok = true
  return ok


check_model_solutions = ->
  ok = false

  $('fieldset.nested_task_model_solutions').each (index, nested_task_model_solution) ->
    if $(nested_task_model_solution).css('display') != 'none'
      description_present = $(nested_task_model_solution).find('.model-solution-description').val().length > 0
      file_present = check_files($(nested_task_model_solution).find('fieldset.nested_fields'))

      if description_present && file_present
        ok = true
  return ok


update_todo_checkbox = (todo_name, is_done) ->
  if is_done
    $(".completeness-checklist-container .todo[data-todo-name=#{todo_name}").removeClass('fa-regular fa-square').addClass('fa-solid fa-square-check').css(color: 'var(--bs-primary)')
  else
    $(".completeness-checklist-container .todo[data-todo-name=#{todo_name}").addClass('fa-regular fa-square').removeClass('fa-solid fa-square-check').css(color: 'inherit')


set_progress = (progress) ->
  old_progress = $('.completeness-checklist-container .progress-bar').attr('aria-valuenow')

  $('.completeness-checklist-container .progress-bar').attr('aria-valuenow', progress).css(width: "#{progress}%")

  # circular progress bar hack with strokeDashoffset
  $circle = $('.minimized-checklist > svg > circle.bar');
  $circle.css({strokeDashoffset: ((100-progress)/100) * Math.PI*($circle.attr('r')*2)});

  $('.minimized-checklist > svg > text').text("#{progress}%");

  if progress > old_progress && progress == 100
    setTimeout ->
      minimize_checklist()
    , 700


update_checklist = ->
  done = 0.0

  todos.forEach (todo) ->
    is_done = check(todo)
    update_todo_checkbox(todo, is_done)
    if is_done
      done += 1.0

  setTimeout ->
    set_progress(Math.round(done / todos.length * 100))
  , 100


$(document).on('turbolinks:load', initialize_checklist)
