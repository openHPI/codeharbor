ready = ->
  initCollapsable($('.description'), '95px')
  window.addEventListener 'resize', -> initCollapsable($('.description'), '95px')
  initializeDynamicHideShow()
  initializeFilter()
  initializeIndexComments()
  initializeInputFieldEnterCallback()


initializeDynamicHideShow = ->
  $('body').on 'click', '.more-btn-wrapper', (event) ->
    event.preventDefault()
    toggleHideShowMore $(this)

initializeSelect2 = ->
  $('.defaultSelect2').select2
    language: I18n.locale
    minimumResultsForSearch: 10
    width: '100%'

  $('.language-box').select2
    language: I18n.locale
    width: '100%'
    multiple: true
    closeOnSelect: false
    placeholder: I18n.t('tasks.javascripts.all_languages')

toggleHideShowMore = (element) ->
  $parent = $(element).parent()
  $toggle = $(element).find '.more-btn'
  $less_tag = $toggle.children '.less-tag'
  $more_tag = $toggle.children '.more-tag'
  $text = $(element).prev()

  if $less_tag.hasClass 'd-none'
    $parent.css 'max-height', 'unset'
    # Save old height somewhere for later use
    $text.prop 'default-max-height', $text.css 'max-height'
    $text.css 'max-height', $text.prop('scrollHeight') + 'px'
  else
    $text.css 'max-height', $text.prop 'default-max-height'
  $less_tag.toggleClass 'd-none'
  $more_tag.toggleClass 'd-none'

initCollapsable = (collapsables, max_height) ->
  collapsables.each ->
    if $(this).prop('scrollHeight') > $(this).prop('clientHeight')
      $(this).css 'height', 'unset'
      $(this).css 'max-height', max_height
      $(this).siblings('.more-btn-wrapper').show()
    else
      $(this).siblings('.more-btn-wrapper').hide()
    addAnimatedSliding()

addAnimatedSliding = ->
  setTimeout ->
    $('.collapsable').addClass('animated-sliding')
  , 100

initializeFilter = ->
  $('#search_title_or_description_cont').keypress (event) ->
    if event.keyCode == 13 || event.which == 13
      event.preventDefault()
      $("#task_search").submit()

  $("#reset-btn").click ->
    $('.ransack-filter').val('').trigger('change')
    $("#task_search").submit()


  $(".change-hidden-field").click ->
    $('#visibility').val(this.id)
    $('#task_search').submit()

  $('.ransack-filter').on 'input change', ->  # Reset pagination if filter changes
    $('#override-page').prop('disabled', false)

  $('#' + $('#visibility').val()).addClass('selected')
  intializeAdvancedFilter()

intializeAdvancedFilter = ->
  $advancedFilterActive = $('#advancedFilterActive')
  $dropdownContent = $('.dropdown-content')
  if $advancedFilterActive
    if $advancedFilterActive.val() == "true"
      $dropdownContent.removeClass('hide')

  $advanced = $('#advanced')
  $drop = $('#drop')
  $advanced.click ->
    $dropdownContent.toggleClass('hide')
    $search = $('#search')
    if $advancedFilterActive.val() == "true"
      $search.css("border-bottom-left-radius", "4px")
      $advanced.css("border-bottom-right-radius", "4px")
      $advancedFilterActive.val(false)
      $drop.removeClass('fa-caret-up').addClass('fa-caret-down')
    else
      $search.css("border-bottom-left-radius", "0px")
      $advanced.css("border-bottom-right-radius", "0px")
      $advancedFilterActive.val(true)
      $drop.removeClass('fa-caret-down').addClass('fa-caret-up')

  if $('#order_param')
    $('#order_created').addClass('active')

  $('#order_created').click ->
    $('#order_created').addClass('active')
    $('#order_rating').removeClass('active')
    $('#order_param').val('order_created')

initializeIndexComments = ->
  $('.index-comment-button').on 'click', ->
    task_id = this.getAttribute("data-task")
    url = Routes.task_comments_path(task_id)
    $comment_box = $(".comment-box[data-task=#{task_id}]")
    $related_box = $(".related-box[data-task=#{task_id}]")

    $caret = $(this).children('.my-caret')
    $wait_icon = $(this).children('.wait')

    if $caret.hasClass('fa-caret-down')
      $caret.removeClass('fa-caret-down').addClass('fa-caret-up')
      loadComments(url, $wait_icon, $comment_box, ->
        if $related_box
          if $related_box.css('display') != 'none'
            $related_box.addClass('with-bottom-border'))
    else
      $caret.removeClass('fa-caret-up').addClass('fa-caret-down')
      $comment_box.addClass('hide')
      if $related_box
        $related_box.removeClass('with-bottom-border')

initializeInputFieldEnterCallback = ->
  $('.input-field-tag').keypress (event) ->
    if (event.key != "Enter")
      return
    $('.search-submit-button-tag').click();
    event.preventDefault();


$(document).on('turbolinks:load', ready)
$(document).on('select2:locales:loaded', initializeSelect2)
