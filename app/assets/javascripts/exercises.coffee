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

loadSelect2 = ->

  $('#select2-control').select2
    tags: false
    width: '20%'
    multiple: false

  $('.my-group2').select2
    tags: true
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
    multiple: false
    maximumSelectionSize: 5
    formatSelectionTooBig: (limit) ->
      'You can only add 5 topics'
    ajax:
      dataType: 'json'
      url: '/file_types/search.json'
      processResults: (data) ->
        { results: $.map(data, (obj) ->
          {
            id: obj.type
            text: obj.type
          }
        ) }

  $('#my-group2').select2
    tags: true
    width: '100%'
    multiple: false

  $('.language-box').select2
    width: '100%'
    multiple: true
    innerHeight: 0.5
    placeholder: "All Languages"

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

  if document.getElementById('window')
    console.log("aloha")
    if document.getElementById('window').value == "true"
      console.log("show dropdown")
      $('.dropdown-content').show()

  $('#advanced').click ->
    $('.dropdown-content').toggle()
    search = $('#search')
    if document.getElementById('window').value == "true"
      $(search).css("border-bottom-left-radius", "4px")
      $("#advanced").css("border-bottom-right-radius", "4px")
      document.getElementById('window').value = false
      $('#drop').removeClass('fa-caret-up').addClass('fa-caret-down')
    else
      $(search).css("border-bottom-left-radius","0px")
      $("#advanced").css("border-bottom-right-radius", "0px")
      document.getElementById('window').value = true
      $('#drop').removeClass('fa-caret-down').addClass('fa-caret-up')


  if order = document.getElementById('order_param')
    $(document.getElementById(order.value)).addClass('active')

  $('#order_rating').click ->
    $('#order_rating').addClass('active')
    $('#order_created').removeClass('active')
    document.getElementById('order_param').value = 'order_rating'

  $('#order_created').click ->
    $('#order_created').addClass('active')
    $('#order_rating').removeClass('active')
    document.getElementById('order_param').value = 'order_created'

$(document).ready(ready)
$(document).on('page:load', ready)
