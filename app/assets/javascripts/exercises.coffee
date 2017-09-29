# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

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

  $('.toggle').on 'click', ->
    $($(this).parent().next()).toggle()
    if $(this).hasClass('fa-caret-down')
      $(this).removeClass('fa-caret-down').addClass('fa-caret-up')
    else
      $(this).removeClass('fa-caret-up').addClass('fa-caret-down')

  $('.comment-button').on 'click', ->
    exercise_id = this.getAttribute("data-exercise")
    caret = $(this).children('.fa')
    comment_box = $(".comment-box[data-exercise=#{exercise_id}]")

    if $(caret).hasClass('fa-caret-down')
      $(caret).removeClass('fa-caret-down').addClass('fa-caret-up')
      $(comment_box).show()
      $.ajax({
        type: 'GET',
        url: window.location.pathname + '/' + exercise_id + "/load_comments"
        dataType: 'script'
      })
    else
      $(caret).removeClass('fa-caret-up').addClass('fa-caret-down')
      $(comment_box).hide()
$(document).ready(ready)
$(document).on('page:load', ready)
# All non-GET requests will add the authenticity token
# if not already present in the data packet

