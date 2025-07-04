current_category_ratings = null
unsaved_category_ratings = null

ready = ->
  current_category_ratings = find_entered_category_ratings()
  unsaved_category_ratings = Object.assign({}, current_category_ratings)
  initializeRatings()

find_entered_category_ratings = ->
  categories = {}

  $('#ratingModal').find('.task-star-rating').each(->
    category_name = $(this).data('rating-category')
    category_value = $(this).find('.fa-solid').length

    categories[category_name] = category_value
  )
  return categories

update_rating_modal_save_button = ->
  valid = true
  for key, value of unsaved_category_ratings when value == 0
    valid = false
  $('#ratingModalSaveButton').prop('disabled', !valid)


reset_category_stars = (category) ->
  $(".task-star-rating[data-is-rating-input='true'][data-rating-category='#{category}'] .rating-star").each(->
    if $(this).data('rating') <= unsaved_category_ratings[category]
      $(this).addClass('fa-solid').removeClass('fa-regular')
    else
      $(this).addClass('fa-regular').removeClass('fa-solid')
  )

reset_unsaved_ratings = ->
  unsaved_category_ratings = Object.assign({}, current_category_ratings)
  for category of unsaved_category_ratings
    reset_category_stars(category)
  update_rating_modal_save_button()

initializeRatings = ->
  $(".task-star-rating[data-is-rating-input='true'] .rating-star").hover(->
    $(this).prevAll().add(this).addClass('fa-solid').removeClass('fa-regular')
    $(this).nextAll().addClass('fa-regular').removeClass('fa-solid')
  )

  $(".task-star-rating[data-is-rating-input='true']").mouseleave(->
    category = $(this).data('rating-category')
    reset_category_stars(category)
  )

  $('#ratingModal').on('hidden.bs.modal', ->
    reset_unsaved_ratings()
  )

  $(".task-star-rating[data-is-rating-input='true'] .rating-star").click(->
    $(this).prevAll().add(this).addClass('fa-solid').removeClass('fa-regular')
    $(this).nextAll().addClass('fa-regular').removeClass('fa-solid')

    clicked_category = $(this).parent().data('rating-category')
    star_idx = $(this).data('rating')

    unsaved_category_ratings[clicked_category] = star_idx

    update_rating_modal_save_button()
  )

  $('#ratingModalSaveButton').click(->
    task_id = $('#ratingModal').data("task-id")

    $.ajax({
      type: "POST",
      url: Routes.task_ratings_path(task_id),
      data: {rating: unsaved_category_ratings},
      dataType: 'json',
      success: (response) ->
        current_category_ratings = Object.assign({}, unsaved_category_ratings)

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


$(document).on('turbo-migration:load', ready)
