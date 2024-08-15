ready = ->
  initializeRatings()

find_entered_category_ratings = ->
  categories = {}

  $('#ratingModal').find('.task-star-rating').each(->
    category_name = $(this).data('rating-category');
    category_value = $(this).find('.fa-solid').length;

    categories[category_name] = category_value;
  )
  return categories

initializeRatings = ->
  $(".task-star-rating[data-is-rating-input='true'] .rating-star").click(->
    $(this).prevAll().add(this).addClass('fa-solid').removeClass('fa-regular');
    $(this).nextAll().addClass('fa-regular').removeClass('fa-solid');

    valid = true;
    for key,value of find_entered_category_ratings() when value == 0
      $('#ratingModalSaveButton').prop('disabled', true);
      valid = false;

    if valid
      $('#ratingModalSaveButton').prop("disabled", false);
  )

  $('#ratingModalSaveButton').click(->
    task_id = $('#ratingModal').data("task-id");
    categories = find_entered_category_ratings();

    $.ajax({
      type: "POST",
      url: Routes.task_ratings_path(task_id),
      data: {rating: categories},
      dataType: 'json',
      success: (response) ->
        Object.keys(response.average_rating).forEach (category) ->
          rating = response.average_rating[category]

          $(".averaged-task-ratings .number-rating[data-rating-category=#{category}]").text(rating)

          $(".averaged-task-ratings .task-star-rating[data-rating-category=#{category}] .rating-star").each(->
            star_idx = $(this).data('rating')
            $(this).removeClass("fa-regular fa-solid fa-star fa-star-half-stroke")

            if rating >= star_idx
              $(this).addClass('fa-solid fa-star')
            else if (Math.round(rating * 2) / 2.0 + 0.5) >= star_idx
              $(this).addClass('fa-regular fa-star-half-stroke')
            else
              $(this).addClass('fa-regular fa-star')
          )
    })
  )


$(document).on('turbolinks:load', ready)
