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

  $('.file-role').select2
    tags: false
    width: '100%'
    multiple: false

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

# toggleDescription = (description) ->
#   dots = $(description).children('.dots')
#   more = $(description).children('.more')
#   toggle = $(description).children('.more-btn')

#   if(more.css('display') == 'none')
#     dots.css 'display', 'none'
#     toggle.html 'Show less'
#     more.css 'display', 'inline'
#     $(description).parent().css 'height', 'unset'
#   else
#     dots.css 'display', 'inline'
#     toggle.html 'Show more'
#     more.css 'display', 'none'
#     $(description).parent().css 'height', '120px'

toggleDescription = (exercise_content) ->

  # dots = $(exercise_content).children('.dots')
  # more = $(exercise_content).children('.more')
  toggle = $(exercise_content).children('.more-btn')
  description = $(exercise_content).children('.description')

  if(toggle.html() == 'Show more')
    # dots.css 'display', 'none'
    # more.css 'display', 'inline'
    toggle.html 'Show less'
    $(exercise_content).css 'height', 'unset'
    description.css 'height', description.prop('scrollHeight')+'px'
  else
    # dots.css 'display', 'inline'
    # more.css 'display', 'none'
    toggle.html 'Show more'
    description.css 'height', '100px'

initDescriptions =->
  $('.description').each ->
    if $(this).prop('scrollHeight') > $(this).prop('clientHeight')
      $(this).css('height', '90px')
      $(this).after('<div class="more-btn">Show more</div>')

ready =->
  initDescriptions()
  $('.more-btn').click ->
    toggleDescription $(this).parent()

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

  $('#file_upload').on 'change', ->
    fullPath = document.getElementById('file_upload').value
    if fullPath
      document.getElementById('file-label').innerHTML = get_filename_from_full_path(fullPath)

  $('.toggle-next').on 'click', ->
    $next = $(this).next()
    $next.toggle()
    $caret = $(this).find('span.fa')
    if $caret.hasClass('fa-caret-down')
      $caret.removeClass('fa-caret-down').addClass('fa-caret-up')
      $(this).removeClass('closed')
    else
      $caret.removeClass('fa-caret-up').addClass('fa-caret-down')
      $(this).addClass('closed')

  $('.comment-button').on 'click', ->
    exercise_id = this.getAttribute("data-exercise")
    if exercise_id
      url = window.location.pathname + '/' + exercise_id + "/comments"
      $comment_box = $(".comment-box[data-exercise=#{exercise_id}]")
      $related_box = $(".related-box[data-exercise=#{exercise_id}]")
    else
      url = window.location.pathname + "/comments"
      $comment_box = $(".comment-box")
    $caret = $(this).children('.my-caret')
    $icon = $(this).children('.wait')

    if $caret.hasClass('fa-caret-down')
      $caret.removeClass('fa-caret-down').addClass('fa-caret-up')
      $.ajax({
        type: 'GET',
        url: url
        dataType: 'script'
        beforeSend: ->
          $icon.show()
        success: ->
          if $related_box
            if $related_box.css('display') != 'none'
              $related_box.addClass('with-bottom-border')
          $comment_box.show()
          anchor = document.getElementById('page_end')
          if anchor
            anchor.scrollIntoView(false)
        complete: ->
          $icon.hide()
      })
    else
      $caret.removeClass('fa-caret-up').addClass('fa-caret-down')
      $comment_box.hide()
      if $related_box
        $related_box.removeClass('with-bottom-border')

  $('.related-button').on 'click', ->
    exercise_id = this.getAttribute("data-exercise")
    if exercise_id
      url = window.location.pathname + '/' + exercise_id + "/related_exercises"
      $related_box = $(".related-box[data-exercise=#{exercise_id}]")
      $comment_box = $(".comment-box[data-exercise=#{exercise_id}]")
    else
      url = window.location.pathname + "/related_exercises"
      $related_box = $(".related-box")
    $caret = $(this).children('.my-caret')
    $icon = $(this).children('.wait')

    if $caret.hasClass('fa-caret-down')
      $.ajax({
        type: 'GET',
        url: url
        dataType: 'script'
        beforeSend: ->
          $icon.show()
        success: ->
          $related_exercises = $related_box.find('.related-exercises')
          $shown_elements = $related_exercises.slice(0,3)
          if $related_exercises.size() > 3
            $related_box.find('.slide-right').removeClass('inactive').addClass('active')
          $shown_elements.addClass('displayed')
          $related_exercises.not($shown_elements).addClass('not-displayed')
          $caret.removeClass('fa-caret-down').addClass('fa-caret-up')
          if $comment_box
            if $comment_box.css('display') != 'none'
              $related_box.addClass('with-bottom-border')
          $related_box.show()
          anchor = document.getElementById('page_end')
          if anchor
            anchor.scrollIntoView(false)
        complete: ->
          $icon.hide()
      })
    else
      $caret.removeClass('fa-caret-up').addClass('fa-caret-down')
      $related_box.hide()
      $related_box.removeClass('with-bottom-border')

  $('.slide-right').on 'click', ->
    if $(this).hasClass('inactive')
      return
    related_exercises = $(this).siblings('.content').children()
    last_shown_element = $(related_exercises).filter('.displayed').last()
    console.log(last_shown_element)
    index = $(related_exercises).index(last_shown_element)
    shown_elements = $(related_exercises).slice(index+1)
    if shown_elements.size() > 3
      $(this).siblings('.slide-left').removeClass('inactive').addClass('active')
      shown_elements = $(related_exercises).slice(index+1, index+4)
      $(shown_elements).removeClass('not-displayed').addClass('displayed')
      $(related_exercises).not(shown_elements).removeClass('displayed').addClass('not-displayed')
    else
      $(this).siblings('.slide-left').removeClass('inactive').addClass('active')
      $(this).removeClass('active').addClass('inactive')
      $(shown_elements).removeClass('not-displayed').addClass('displayed')
      $(related_exercises).not(shown_elements).removeClass('displayed').addClass('not-displayed')

  $('.slide-left').on 'click', ->
    if $(this).hasClass('inactive')
      return
    related_exercises = $(this).siblings('.content').children()
    first_shown_element = $(related_exercises).filter('.displayed').first()
    index = $(related_exercises).index(first_shown_element)
    shown_elements = $(related_exercises).slice(index-3, index)
    $(shown_elements).removeClass('not-displayed').addClass('displayed')
    $(related_exercises).not(shown_elements).removeClass('displayed').addClass('not-displayed')
    if index = 3
      $(this).removeClass('active').addClass('inactive')
    $(this).siblings('.slide-right').removeClass('inactive').addClass('active')

  if document.getElementById('window')
    if document.getElementById('window').value == "true"
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

  #Set link for license
  if select = document.getElementById('exercise_license_id')
    option = select.getElementsByTagName('option')[select.selectedIndex]
    link = option.getAttribute("data-link")
    $('.link').html("<p>Link: <a href='#{link}'>#{link}</a></p>")

  $('.select select').on 'change', ->
    option = this.getElementsByTagName('option')[this.selectedIndex]
    link = option.getAttribute("data-link")
    $('.link').html("<p>Link: <a href='#{link}'>#{link}</a></p>")

$(document).on('turbolinks:load', ready)
