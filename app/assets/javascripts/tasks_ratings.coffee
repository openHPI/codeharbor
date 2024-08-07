ready = ->
  initializeRatings()

initializeRatings = ->
  $(".task-star-rating[data-is-rating-input='true'] .rating-star").hover(->
    $(this).prevAll().add(this).addClass('fa-solid').removeClass('fa-regular');
    $(this).nextAll().addClass('fa-regular').removeClass('fa-solid');
  )

  $('#ratingModalSaveButton').on 'click', ->
    modal = $('#ratingModal');

    task_id = $(modal).data("task-id");
    categories = {};
    modal.find('.task-star-rating').each(->
      categories[$(this).data('rating-category')] = $(this).find('.fa-solid').length;
    )

    $.ajax({
      type: "POST",
      url: Routes.task_ratings_path(task_id),
      data: {rating: categories},
      dataType: 'json',
      success: (response) ->
        console.log(response.average_rating)

        Object.keys(response.average_rating).forEach (category) ->
          rating = response.average_rating[category]

          $(".averaged-task-ratings .number-rating[data-rating-category=#{category}]").text(rating)

          $(".averaged-task-ratings .task-star-rating[data-rating-category=#{category}] .rating-star").each(->
            star_idx = $(this).data('rating')
            $(this).removeClass("fa-regular fa-solid fa-star fa-star-half-stroke")

            console.log(rating, Math.round(rating * 2) / 2.0 + 0.5, star_idx)

            if rating >= star_idx
              $(this).addClass('fa-solid fa-star')
            else if (Math.round(rating * 2) / 2.0 + 0.5) >= star_idx
              $(this).addClass('fa-regular fa-star-half-stroke')
            else
              $(this).addClass('fa-regular fa-star')
          )
    })


$(document).on('turbolinks:load', ready)
