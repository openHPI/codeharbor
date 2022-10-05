ready =->
  initializeRatings()

$(document).on('turbolinks:load', ready)

initializeRatings = ->
  USERRATING = 0

#  $('.popup-rating').hover (->
#    USERRATING = $('.rating span.fa-star').last().attr("data-rating")
#  ), ->
#    lower = $('.rating span').filter (->
#      $(this).attr("data-rating") <= USERRATING
#    )
#    $(lower).removeClass("fa-star-o").addClass("fa-star")
#    upper = $('.rating span').filter (->
#      $(this).attr("data-rating") > USERRATING
#    )
#    $(upper).removeClass("fa-star").addClass("fa-star-o")

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
    rating = this.getAttribute("data-rating")
#    $(this).removeClass("fa-star-o").addClass("fa-star")
#    lower = $('.rating span').filter (->
#      $(this).attr("data-rating") < rating
#    )
#    $(lower).removeClass("fa-star-o").addClass("fa-star")
#    upper = $('.rating span').filter (->
#      $(this).attr("data-rating") > rating
#    )
#    $(upper).removeClass("fa-star").addClass("fa-star-o")

#    loc = window.location.pathname
#    dir = loc.substring(0, loc.lastIndexOf('/'))

    $.ajax({
      type: "POST",
      url: window.location.pathname + "/ratings",
      data: {rating: {rating: rating}, commit: "Save Rating"},
      dataType: 'json',
      success: (response) ->
        rating = response.user_rating.rating
#        USERRATING = rating
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
