# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$star_rating = $('.star-rating .fa')

SetRatingStar = ->
  $star_rating.each ->
    if parseInt($star_rating.siblings('input.rating-value').val()) >= parseInt($(this).data('rating'))
      console.log 'rating1'
      $(this).removeClass('fa-star-o').addClass('fa-star')
    else
      console.log 'rating2'
      $(this).removeClass('fa-star').addClass('fa-star-o')

$star_rating.on 'click', ->
  $star_rating.siblings('input.rating-value').val $(this).data('rating')
  SetRatingStar()

SetRatingStar()

ready =->
  $(".change-hidden-field").click ->
    value = (this).id
    document.getElementById('option').value = value
    $(".index").submit()

  if option = document.getElementById('option')
    $(document.getElementById(option.value)).addClass('selected')

  if document.getElementById('group-field')
    elem = document.getElementById('group-field')
    if document.getElementById('exercise_private_false').checked == true
      $(elem).hide()

    $("#exercise_private_true").click ->
      $(elem).show()

    $("#exercise_private_false").click ->
      $(elem).hide()

    $('.my-groups').select2
      width: '100%'
      createSearchChoice: (term, data) ->
        if $(data).filter((->
          @text.localeCompare(term) == 0
        )).length == 0
          return {
            id: term
            text: term
          }
        return
      multiple: true
      maximumSelectionSize: 5
      formatSelectionTooBig: (limit) ->
        'You can only add 5 topics'
      ajax:
        dataType: 'json'
        url: '/groups/search.json'
        processResults: (data) ->
          { results: $.map(data, (obj) ->
            {
              id: obj.name
              text: obj.name
            }
          ) }
    return
$(document).ready(ready)
$(document).on('page:load', ready)