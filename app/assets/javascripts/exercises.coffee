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
