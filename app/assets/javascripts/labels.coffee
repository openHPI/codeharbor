ready = ->
  $('.my-tag').select2
    width: '100%'
    multiple: true
    maximumSelectionLength: 5
    closeOnSelect: false

    templateSelection: (data, container) ->
      $(container).css("background-color", "#"+$(data.element).attr("label_color"));
      $(container).css("color", "#"+$(data.element).attr("label_font_color"));
      $(container).children("span").css("color", "#"+$(data.element).attr("label_font_color"));

      $template = $('<span></span>').text(data.text);
      $template.css({"font-size" : "80%", "font-weight" : "bold", "color" : "#"+$(data.element).attr("label_font_color")});
      return $template;

    templateResult: (data, container) ->
      $template = $('<div></div>').text(data.text).addClass("exercise_label");
      $template.css({"background-color" : "#"+$(data.element).attr("label_color"), "color" : "#"+$(data.element).attr("label_font_color")});
      return $template;

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
