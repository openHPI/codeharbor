ready = ->
  $('.my-tag').select2
    width: '100%'
    tags: true
    multiple: true
    maximumSelectionLength: 5
    closeOnSelect: false
    tokenSeparators: [',']

    ajax: {
      url: '/labels/search',
      dataType: 'json',
      data: (params) ->
        query = {
          search: params.term,
          page: params.page || 1
        }
        return query;
    }

    templateSelection: (data, container) ->
      text = data.text;
      bg_color = "#" + ($(data.element).attr("label_color") || data.label_color || "e4e4e4");
      color = "#" + ($(data.element).attr("label_font_color") || data.label_font_color || "000000");

      if data.newTag == true
        text += " (new)";

      $(container).css({"background-color" : bg_color, "color" : color});
      $(container).children("span").css("color", color);

      $template = $('<span></span>').text(text);
      $template.css({"font-size" : "80%", "font-weight" : "bold"});
      return $template;

    templateResult: (data) ->
      if (data.loading)
        return data.text;

      text = data.text;
      bg_color = "#" + (data.label_color || "e4e4e4");
      color = "#" + (data.label_font_color || "000000");

      if data.newTag == true
        text += " (new)";

      $template = $('<div></div>').text(text).addClass("task_label");
      $template.css({"background-color" : bg_color, "color" : color});
      return $template;

    createTag: (params) ->
      term = $.trim(params.term)
      selection = $('#task_label_names').select2('data').map (element) -> element.id

      if term == '' || term.length > 15 || selection.includes(term)
        return null;

      return {
        id: term,
        text: term,
        newTag: true
      }

    formatSelectionTooBig: (limit) ->
      I18n.t('labels.can_only_create_5')

    $('#task_label_names').on 'select2:select', clear_input
  return

clear_input = ->
  $('#task_label_names').siblings(".select2").find("input").val("");
  return

$(document).on 'turbolinks:load', ready
