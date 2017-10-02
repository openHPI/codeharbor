# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

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

  $('.file-type').select2
    tags: false
    width: '100%'
    multiple: false

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

  USERRATING = 0

  $('.popup-rating').hover (->
    USERRATING = $('.rating span.fa-star').last().attr("data-rating")
  ), ->
    lower = $('.rating span').filter (->
      $(this).attr("data-rating") <= USERRATING
    )
    $(lower).removeClass("fa-star-o").addClass("fa-star")
    upper = $('.rating span').filter (->
      $(this).attr("data-rating") > USERRATING
    )
    $(upper).removeClass("fa-star").addClass("fa-star-o")

  $('.rating span').hover (->
    $(this).removeClass("fa-star-o").addClass("fa-star")
    rating = this.getAttribute("data-rating")
    lower = $('.rating span').filter (->
      $(this).attr("data-rating") < rating
    )
    $(lower).removeClass("fa-star-o").addClass("fa-star")
    upper = $('.rating span').filter (->
      $(this).attr("data-rating") > rating
    )
    $(upper).removeClass("fa-star").addClass("fa-star-o")
  )

  $('.rating span').on 'click', ->
    $(this).removeClass("fa-star-o").addClass("fa-star")
    rating = this.getAttribute("data-rating")
    lower = $('.rating span').filter (->
      $(this).attr("data-rating") < rating
    )
    $(lower).removeClass("fa-star-o").addClass("fa-star")
    upper = $('.rating span').filter (->
      $(this).attr("data-rating") > rating
    )
    $(upper).removeClass("fa-star").addClass("fa-star-o")

    loc = window.location.pathname
    dir = loc.substring(0, loc.lastIndexOf('/'))

    $.ajax({
      type: "POST",
      url: window.location.pathname + "/ratings",
      data: {rating: {rating: rating}, commit: "Save Rating"},
      dataType: 'json',
      success: (response) ->
        rating = response.user_rating.rating
        USERRATING = rating
        stars = $('.rating span').filter (->
          $(this).attr("data-rating") <= rating
        )
        $(stars).removeClass("fa-star-o").addClass("fa-star")

        overallrating = response.overall_rating
        $('.starrating span.fa.fa-star[data-rating=1]').attr("color", "red")
        for num in [1,2,3,4,5]
          do (num) ->
            if overallrating >= num
              $('.overall-rating[data-rating='+num+']').removeClass("fa-star-o").removeClass("fa-star-half-o").addClass("fa-star")
            else if (overallrating + 0.5) >= num
              $('.overall-rating[data-rating='+num+']').removeClass("fa-star-o").removeClass("fa-star").addClass("fa-star-half-o")
            else
              $('.overall-rating[data-rating='+num+']').removeClass("fa-star").removeClass("fa-star-half-o").addClass("fa-star-o")
      error: (a, b, c) ->
        alert("error:" + c);
    })

  $('#xml-import').on 'click', (e) ->
    e.stopPropagation()
    return

  $('#xml').on 'change', ->
    fullPath = document.getElementById('xml').value
    if fullPath
      startIndex = if fullPath.indexOf('\\') >= 0 then fullPath.lastIndexOf('\\') else fullPath.lastIndexOf('/')
      filename = fullPath.substring(startIndex)
      if filename.indexOf('\\') == 0 or filename.indexOf('/') == 0
        filename = filename.substring(1)
      document.getElementById('xml-label').innerHTML = filename

  $('.toggle').on 'click', ->
    $($(this).parent().next()).toggle()
    if $(this).hasClass('fa-caret-down')
      $(this).removeClass('fa-caret-down').addClass('fa-caret-up')
    else
      $(this).removeClass('fa-caret-up').addClass('fa-caret-down')

  $('.comment-button').on 'click', ->
    exercise_id = this.getAttribute("data-exercise")
    if exercise_id
      url = window.location.pathname + '/' + exercise_id + "/comments"
      comment_box = $(".comment-box[data-exercise=#{exercise_id}]")
    else
      url = window.location.pathname + "/comments"
      comment_box = $(".comment-box")
    caret = $(this).children('.fa')

    if $(caret).hasClass('fa-caret-down')
      $(caret).removeClass('fa-caret-down').addClass('fa-caret-up')
      $.ajax({
        type: 'GET',
        url: url
        dataType: 'script'
        success: ->
          $(comment_box).show()
          anchor = document.getElementById('page_end')
          if anchor
            anchor.scrollIntoView(false)
      })
    else
      $(caret).removeClass('fa-caret-up').addClass('fa-caret-down')
      $(comment_box).hide()

  if document.getElementById('window')
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

  $('.exercise-validation').on('submit', validateForm)

$(document).ready(ready)
$(document).on('page:load', ready)
