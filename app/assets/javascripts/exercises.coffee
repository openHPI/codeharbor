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

toggleHideShowMore = (element) ->
  $parent = $(element).parent()
  $toggle = $(element).find '.more-btn'
  $less_tag = $toggle.children '.less-tag'
  $more_tag = $toggle.children '.more-tag'
  $text = $(element).prev()

  if $less_tag.hasClass 'hidden'
    $parent.css 'max-height', 'unset'
    # Save old height somewhere for later use
    $text.prop 'default-max-height', $text.css 'max-height'
    $text.css 'max-height', $text.prop('scrollHeight')+'px'
  else
    $text.css 'max-height', $text.prop 'default-max-height'
  $less_tag.toggleClass 'hidden'
  $more_tag.toggleClass 'hidden'

initCollapsable = (collapsables, max_height) ->
  collapsables.each ->
    if $(this).prop('scrollHeight') > $(this).prop('clientHeight')
      $(this).css 'height', 'unset'
      $(this).css 'max-height', max_height
    else
      $(this).siblings('.more-btn-wrapper').hide()
    addAnimatedSliding()

addAnimatedSliding =->
  setTimeout ->
    $('.collapsable').addClass('animated-sliding')
  , 100

ready =->
  initCollapsable($('.description'), '95px')

  $('body').on 'click', '.more-btn-wrapper', (event) ->
    event.preventDefault()
    toggleHideShowMore $(this)

  $('body').on 'click', '.open-link', (event) ->
    Turbolinks.visit($(this).prop('href'))

  $("#reset-btn").click ->
    $('#search').attr('value', '')
    $(".index").submit()


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

  $('#import-exercise-button').on 'click', (e) ->
    e.preventDefault()
    e.stopPropagation()
    console.log('click')
    importExerciseStart()
    # return false

  $('#exercise_import').on 'change', ->
    fullPath = document.getElementById('exercise_import').value
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
          initCollapsable($('.small-description'), '58px')
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
    # console.log(last_shown_element)
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

  $('.history-button').on 'click', ->
    exercise_id = this.getAttribute("data-exercise")
    url = window.location.pathname + "/history"
    $history_box = $(".history-box")

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
          $history_box.show()
          anchor = document.getElementById('page_end')
          if anchor
            anchor.scrollIntoView(false)
        complete: ->
          $icon.hide()
      })
    else
      $caret.removeClass('fa-caret-up').addClass('fa-caret-down')
      $history_box.hide()

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

  $('.state-tag-remove-button').on 'click', (event) ->
    target = $(event.target)
    exercise_id = target.attr('data-id')
    $.ajax({
      type: "POST",
      url: '/exercises/' + exercise_id + "/remove_state",
      dataType: 'json',
      success: (response) ->
        target.parents('.state-tag-dropdown').hide()
      error: (a, b, c) ->
        alert("error:" + c);
    })

  $('body').on 'click', '.primary-checkbox', (event) ->
    $('.primary-checkbox').prop('checked', false)
    $(event.target).prop('checked', true)

  $('body').on 'click', '.export-action', (event) ->
    exportType = $(this).attr('data-export-type')
    exerciseID = $(this).parents('.import-export-exercise').attr('data-exercise-id')
    accountLinkID = $(this).parents('.import-export-exercise').attr('data-account-link')
    exportExerciseConfirm(exerciseID, accountLinkID, exportType)

  $('body').on 'click', '.export-close-button', (event) ->
    $(this).parents('.import-export-exercise').remove()

  $('body').on 'click', '.import-action', (event) ->
    importId = $(this).parents('.import-export-exercise').attr('data-import-id')
    subfileId = $(this).parents('.import-export-exercise').attr('data-import-subfile-id')
    importType = $(this).attr('import-type')
    importExerciseConfirm(importId, subfileId, importType)


  if $('.primary-checkbox').length > 0 && $('.primary-checkbox:checked').length < 1
    $('.primary-checkbox')[0].click()

$(document).on('turbolinks:load', ready)

importExerciseStart = () -> #maybe unobstrusive like export?
  # console.log('start')
  formData = new FormData()
  formData.append('zip_file', document.getElementById('exercise_import').files[0])

  $.ajax({
    type: 'POST',
    url: '/exercises/import_exercise_start',
    data: formData,
    processData: false,
    contentType: false,
    # success: (response) ->
      # console.log(response)
    error: (a, b, c) ->
      alert('error: ' + c)
  })

importExerciseConfirm = (importId, subfileId, importType) ->
  $exerciseDiv = $('[data-import-subfile-id=' + subfileId + ']')
  $messageDiv = $exerciseDiv.children('.import-export-message')
  $actionsDiv = $exerciseDiv.children('.import-export-exercise-actions')

  $.ajax({
    type: 'POST',
    url: '/exercises/import_exercise_confirm',
    data: {import_id: importId, subfile_id: subfileId, import_type: importType},
    dataType: 'json',
    success: (response) ->
      console.log('Confirm done')
      console.log(response)
      $messageDiv.html response.message
      $actionsDiv.html response.actions

      if response.status == 'success'
        $exerciseDiv.addClass 'import-export-success'
      else
        $exerciseDiv.addClass 'import-export-failure'
    error: (a, b, c) ->
      alert('error: ' + c)
  })


exportExerciseStart = (exerciseID) ->
  $exerciseDiv = $('#export-exercise-' + exerciseID)
  accountLinkID = $exerciseDiv.attr('data-account-link')
  $messageDiv = $exerciseDiv.children('.import-export-message')
  $actionsDiv = $exerciseDiv.children('.import-export-exercise-actions')

  $messageDiv.html('Checking if the exercise exists on Codeocean.')
  $actionsDiv.html('<div class="spinner-border"></div>')

  $.ajax({
    type: 'POST',
    url: '/exercises/' + exerciseID + '/export_external_check',
    data: {account_link: accountLinkID},
    dataType: 'json',
    success: (response) ->
      # if response.error
      #   $messageDiv.html(response.error)
      #   $actionsDiv.html('Retry?')

      $messageDiv.html(response.message)
      $actionsDiv.html(response.actions)
    error: (a, b, c) ->
      alert('error:' + c);
  })


exportExerciseConfirm = (exerciseID, accountLinkID, pushType) ->
  $exerciseDiv = $('#export-exercise-' + exerciseID)
  $messageDiv = $exerciseDiv.children('.import-export-message')
  $actionsDiv = $exerciseDiv.children('.import-export-exercise-actions')

  $.ajax({
    type: 'POST',
    url: '/exercises/' + exerciseID + '/export_external_confirm',
    data: {account_link: accountLinkID, push_type: pushType},
    dataType: 'json',
    success: (response) ->
      $messageDiv.html response.message
      $actionsDiv.html response.actions

      if response.status == 'success'
        $exerciseDiv.addClass 'import-export-success'
      else
        $exerciseDiv.addClass 'import-export-failure'

      # checkExportDialog()
    error: (a, b, c) ->
      alert('error:' + c)
  })

# checkExportDialog = () ->
  # if $('#import-export-modal-body').children(':not(.import-export-success)').length == 0
  #   setTimeout (-> $('#import-export-dialog').modal('hide')), 3000

# export function to make it accessible from outside this scope
root = exports ? this; root.exportExerciseStart = exportExerciseStart
