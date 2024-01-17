# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
ready =->
  $('#share-menu').on 'click', (e) ->
    e.stopPropagation()
    return
  $('#collection-tasks-sortable').sortable({
    handle: '.sortable-handle',
    update: update_collections_tasks_order
  });

update_collections_tasks_order = (e) ->
  # order gets reversed because higher rank = higher on the list
  for input_element, index in $('#collection-tasks-sortable .row input').get().reverse()
    $(input_element).val(index);

$(document).on('turbolinks:load', ready)
