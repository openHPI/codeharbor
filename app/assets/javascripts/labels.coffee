ready = ->
  $('.my-tag').select2
    width: '100%'
    multiple: true
    maximumSelectionLength: 5
    closeOnSelect: false

    templateSelection: (data, container) ->
      $(container).css("background-color", "#"+$(data.element).attr("label_color"));
      $(container).children("span").css("color", "black");
      return $('<span></span>').text(data.text).css({"font-size":"80%", "font-weight":"bold", "color":"black"});

    templateResult: (data, container) ->
      return $('<div></div>').text(data.text).addClass("exercise_label").css("background-color", "#"+$(data.element).attr("label_color"));

    createSearchChoice: (term, data) ->
      if $(data).filter((->
        @text.localeCompare(term) == 0
      )).length == 0
        return {
          id: term
          text: term
        }
      return

    formatSelectionTooBig: (limit) ->
      I18n.t('labels.can_only_create_5')
  return

$(document).on 'turbolinks:load', ready
