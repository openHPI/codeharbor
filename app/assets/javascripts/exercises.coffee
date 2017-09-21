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
        console.log('user rating' +rating)
        USERRATING = rating
        stars = $('.rating span').filter (->
          $(this).attr("data-rating") <= rating
        )
        $(stars).removeClass("fa-star-o").addClass("fa-star")

        overallrating = response.overall_rating
        console.log('overall rating' + overallrating)
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

  #$('#import-button').on 'click', ->
   # file_data = $('#xml').prop('files')[0]
    # Getting the properties of file from file field
   # form_data = new FormData
    # Creating object of FormData class
   # form_data.append 'file', file_data
    # Appending parameter named file with properties of file_field to form_data
    # form_data.append 'user_id', 123
    # Adding extra parameters to form_data
   # $.ajax
    #  url: window.location.pathname + '/import_exercise'
     # dataType: 'script'
     # cache: false
     # contentType: false
     # processData: false
     # data: form_data
     # type: 'post'
   # return

$(document).ready(ready)
$(document).on('page:load', ready)

jQuery(document).ready ->
# All non-GET requests will add the authenticity token
# if not already present in the data packet

