get_max_label_length = ->
  if (this._max_label_length == undefined)
    this._max_label_length = $('#label-settings').data('max-length');
  return this._max_label_length;

verify_label_name = (label_name) ->
  if label_name == ''
    return I18n.t('labels.javascripts.cannot_be_empty');
  if label_name.length > get_max_label_length()
    return I18n.t('labels.javascripts.too_long');
  return I18n.t('labels.javascripts.ok');

root = exports ? this;
root.verify_label_name = verify_label_name;

ready = ->
  default_label_color = "e4e4e4"
  default_label_font_color = "000000"

  $('.labels-select2-tag').select2
    language: I18n.locale
    width: '100%'
    tags: true
    multiple: true
    maximumSelectionLength: 10
    maximumInputLength: get_max_label_length()
    closeOnSelect: false
    tokenSeparators: [',']

    ajax: {
      url: '/labels/search',
      dataType: 'json',
      data: (params) ->
        query = {
          q: {name_i_cont: params.term},
          page: params.page || 1
        }
        return query;

      processResults: (data) ->
        return {
          pagination: data.pagination
          results: data.results.map (l) -> {
            id: l.name,
            text: l.name,
            label_color: l.color,
            label_font_color: l.font_color
          }
        };

    }

    templateSelection: (data, container) ->
      text = data.text;
      bg_color = "#" + (data.label_color || $(data.element).attr("label_color") || default_label_color);
      color = "#" + (data.label_font_color || $(data.element).attr("label_font_color") || default_label_font_color);

      if data.newTag == true
        text += I18n.t('labels.javascripts.new.selection_suffix');

      $(container).css({"background-color": bg_color, "color": color});
      $(container).children("span").css("color", color);

      $template = $('<span></span>').text(text);
      $template.css({"font-size": "80%", "font-weight": "bold"});
      return $template;

    templateResult: (data) ->
      if (data.loading)
        return data.text;

      text = data.text;
      bg_color = "#" + (data.label_color || default_label_color);
      color = "#" + (data.label_font_color || default_label_font_color);

      if data.newTag == true
        text += I18n.t('labels.javascripts.new.selection_suffix');

      $template = $('<div></div>').text(text).addClass("task_label");
      $template.css({"background-color": bg_color, "color": color});
      return $template;

    createTag: (params) ->
      term = $.trim(params.term)
      selection = $('.labels-select2-tag').select2('data').map (element) -> element.id

      if verify_label_name(term) != I18n.t('labels.javascripts.ok') || selection.includes(term)
        return null;

      return {
        id: term,
        text: term,
        newTag: true
      }

    formatSelectionTooBig: (limit) ->
      I18n.t('labels.javascripts.max_limit_reached', {limit: limit})

    $('.labels-select2-tag').on 'select2:select', clear_input
  $(document).one('turbo:visit', destroy_select2);
  return

clear_input = ->
  $('.labels-select2-tag').siblings(".select2").find("textarea").val("");
  return

destroy_select2 = ->
  selectElement = $('.labels-select2-tag');
  selectElement.select2('destroy');
  selectElement.off('select2:select');
  return


root = exports ? this;
root.verify_label_name = verify_label_name;

$(document).on('select2:locales:loaded', ready)
