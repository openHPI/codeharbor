# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

SetRatingStar = ->
  $(".star-rating").each ->
    if parseInt($star_rating.siblings('input.rating-value').val()) >= parseInt($(this).data('rating'))
      console.log 'rating1'
      $(this).removeClass('fa-star-o').addClass('fa-star')
    else
      console.log 'rating2'
      $(this).removeClass('fa-star').addClass('fa-star-o')

validateForm = (e) ->
  title = document.getElementById('exercise_title')
  if title.value == ''
    if $('#error').length

    else
      title.style.borderColor = "red"
      $("<p id='error' style='color: red'>Title can't be blank</p>").insertAfter(title)
    document.body.scrollTop = document.documentElement.scrollTop = 0;
    e.preventDefault()
    false


loadSelect2 = ->
  $('#select2-control').select2
    tags: false
    width: '20%'
    multiple: false

  $('.file_type').select2
    tags: true
    width: '100%'
    multiple: false

  $('.my-group').select2
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

  $(document).on "fields_added.nested_form_fields", (event, param) ->
    loadSelect2()

  loadSelect2()

  $('.exercise-validation').on('submit', validateForm)

  $(".star-rating").click ->
    $star_rating.siblings('input.rating-value').val $(this).data('rating')
    SetRatingStar()





$(document).ready(ready)
$(document).on('page:load', ready)
