ready =->
  initializeRatings()

$(document).on('turbolinks:load', ready)

initializeRatings = ->
  $('.rating span').hover (->
    $(this).removeClass("fa-regular").addClass("fa-solid")
    rating = this.getAttribute("data-rating")
    lower = $('.rating span').filter (->
      $(this).attr("data-rating") < rating
    )
    $(lower).removeClass("fa-regular").addClass("fa-solid")
    upper = $('.rating span').filter (->
      $(this).attr("data-rating") > rating
    )
    $(upper).removeClass("fa-solid").addClass("fa-regular")
  )

  $('.rating span').on 'click', ->
    rating = this.getAttribute("data-rating")
    task_id = this.parentElement.getAttribute("data-task-id")

    $.ajax({
      type: "POST",
      url: Routes.task_ratings_path(task_id),
      data: {rating: {rating: rating}, commit: "Save Rating"},
      dataType: 'json',
      success: (response) ->
        rating = response.user_rating.rating
#        USERRATING = rating
        stars = $('.rating span').filter (->
          $(this).attr("data-rating") <= rating
        )
        $(stars).removeClass("fa-regular").addClass("fa-solid")

        overallrating = response.overall_rating
        $('.starrating span.fa-solid.fa-star[data-rating=1]').attr("color", "red")
        for num in [1,2,3,4,5]
          do (num) ->
            if overallrating >= num
              $('.overall-rating[data-rating='+num+']').removeClass("fa-star").removeClass("fa-star-half-stroke").removeClass("fa-regular").addClass("fa-star").addClass("fa-solid")
            else if (overallrating + 0.5) >= num
              $('.overall-rating[data-rating='+num+']').removeClass("fa-star").removeClass("fa-solid").addClass("fa-star-half-stroke")
            else
              $('.overall-rating[data-rating='+num+']').removeClass("fa-star-half-stroke").removeClass("fa-solid").addClass("fa-star").addClass("fa-regular")
      error: (_xhr, _textStatus, message) ->
        alert("#{I18n.t('common.javascripts.error')}: #{message}");
    })
