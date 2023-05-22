ready = ->
  max_label_length = 15
  default_label_color = "e4e4e4"
  default_label_font_color = "000000"

  $('.my-tag').select2
    width: '100%'
    tags: true
    multiple: true
    maximumSelectionLength: 5
    maximumInputLength: max_label_length
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
      bg_color = "#" + (data.label_color || $(data.element).attr("label_color") || default_label_color);
      color = "#" + (data.label_font_color || $(data.element).attr("label_font_color") || default_label_font_color);

      if data.newTag == true
        text += I18n.t('labels.new.selection_suffix');

      $(container).css({"background-color" : bg_color, "color" : color});
      $(container).children("span").css("color", color);

      $template = $('<span></span>').text(text);
      $template.css({"font-size" : "80%", "font-weight" : "bold"});
      return $template;

    templateResult: (data) ->
      if (data.loading)
        return data.text;

      text = data.text;
      bg_color = "#" + (data.label_color || default_label_color);
      color = "#" + (data.label_font_color || default_label_font_color);

      if data.newTag == true
        text += I18n.t('labels.new.selection_suffix');

      $template = $('<div></div>').text(text).addClass("task_label");
      $template.css({"background-color" : bg_color, "color" : color});
      return $template;

    createTag: (params) ->
      term = $.trim(params.term)
      selection = $('.my-tag').select2('data').map (element) -> element.id

      if term == '' || term.length > max_label_length || selection.includes(term)
        return null;

      return {
        id: term,
        text: term,
        newTag: true
      }

    formatSelectionTooBig: (limit) ->
      I18n.t('labels.can_only_create_5')

    $('.my-tag').on 'select2:select', clear_input
  return

clear_input = ->
  $('.my-tag').siblings(".select2").find("input").val("");
  return

$(document).on 'turbolinks:load', ready
