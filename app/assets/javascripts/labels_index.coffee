class LabelsTable
  constructor: (@table_container) ->
    @more_labels_loadable = true;
    @waiting_for_response = false;
    @last_loaded_page = 0;
    @sort_by_column = "id";
    @sort_by_order = "asc";
    @name_filter = "";
    @selected_label_ids = [];
    @loaded_labels = {};

    @table_body = @table_container.find('tbody');
    @delete_labels_button = $('#delete-labels-button');
    @merge_labels_button = $('#merge-labels-button');
    @merge_labels_input = $('#merge-labels-input');
    @recolor_labels_button = $('#change-label-color-button');
    @recolor_labels_input = $('#color-labels-input');
    @name_filter_input = $('#label-name-filter-input');

    @table_container.find('.sort-by-id').on 'click', => @sort_button_clicked('id');
    @table_container.find('.sort-by-name').on 'click', => @sort_button_clicked('name');
    @table_container.find('.sort-by-created-at').on 'click', => @sort_button_clicked('created_at');
    @table_container.on 'scroll', (event) => @load_more_rows_if_necessary();
    @name_filter_input.on 'change', (event) => @update_name_filter();

    @delete_labels_button.on 'click', => @delete_selected_labels();
    @merge_labels_button.on 'click', => @merge_selected_labels();
    @recolor_labels_button.on 'click', => @recolor_selected_labels();

    @reload_table();

  update_buttons: () =>
    @delete_labels_button.attr("disabled", @selected_label_ids.length == 0);
    @merge_labels_button.attr("disabled", @selected_label_ids.length == 0);
    @recolor_labels_button.attr("disabled", @selected_label_ids.length == 0);

  update_name_filter: () =>
    @name_filter = @name_filter_input.val();
    @reload_table();

  reload_table: () =>
    @table_body.find('tr').remove();
    @loaded_labels = {};
    @selected_label_ids = [];
    @more_labels_loadable = true;
    @waiting_for_response = false;
    @last_loaded_page = 0;
    @update_buttons();
    @load_more_rows_if_necessary();

  append_new_row: (id, color, font_color, name, created_at, used_by_tasks) =>
    @loaded_labels[id] = {name: name, used_by_tasks: used_by_tasks};

    label = $("<div></div>")
      .addClass('task_label')
      .attr('style', "background-color: #{'#' + color}; color: #{'#' + font_color};")
      .text(name);

    new_row = $('<tr></tr>')
      .append($('<td></td>').text(id))
      .append($('<td></td>').append(label))
      .append($('<td></td>').text(created_at))
      .append($('<td></td>').text(used_by_tasks))
      .attr('label_id', id);

    new_row.on 'click', (event) => @on_row_clicked(event);
    @table_body.append(new_row);

  load_more_rows_if_necessary: () =>
    if @more_labels_loadable && @waiting_for_response == false && @table_container.get(0).clientHeight + @table_container.get(0).scrollTop > @table_container.get(0).scrollHeight * 0.8
      @send_data_request();

  send_data_request: () =>
    $.ajax({
      url: "/labels/search",
      type: "GET",
      data: {
        page: @last_loaded_page + 1
        q: {s: @sort_by_column + " " + @sort_by_order, name_i_cont: @name_filter}
        more_info: true
      },
      success: @handle_data_response
    });
    @waiting_for_response = true;

  handle_data_response: (response) =>
    @more_labels_loadable = response.pagination.more;
    @last_loaded_page += 1;
    @waiting_for_response = false;

    for new_label in response.results
      @append_new_row(new_label.id, new_label.color, new_label.font_color, new_label.name, new_label.created_at, new_label.used_by_tasks);

    @load_more_rows_if_necessary();

  on_row_clicked: (event) =>
    label_id = parseInt($(event.currentTarget).attr("label_id"));

    if @selected_label_ids.includes(label_id)
      @selected_label_ids = @selected_label_ids.filter (id) -> id != label_id
      $(event.currentTarget).removeClass('selected');
    else
      @selected_label_ids.push(label_id);
      $(event.currentTarget).addClass('selected');

    if @selected_label_ids.length == 0
      @merge_labels_input.val("");
    else
      most_used_selected_label_id = @selected_label_ids.reduce (max_id, id) => if @loaded_labels[id].used_by_tasks > @loaded_labels[max_id].used_by_tasks then id else max_id;
      @merge_labels_input.val(@loaded_labels[most_used_selected_label_id].name);

    @update_buttons();

  sort_button_clicked: (sort_by) =>
    $('.sort-by-id, .sort-by-name, .sort-by-created-at')
      .removeClass('table-header-sort-down')
      .removeClass('table-header-sort-up');

    @sort_by_column = sort_by;

    if @sort_by_order == 'desc'
      @sort_by_order = 'asc';
      $(event.target).addClass('table-header-sort-down');
    else
      @sort_by_order = 'desc';
      $(event.target).addClass('table-header-sort-up');
    @reload_table();

  delete_selected_labels: () =>
    confirm_msg = I18n.t('labels.javascripts.delete_confirmation', {selected_labels_count: @selected_label_ids.length});

    if (confirm(confirm_msg))
      requests = []
      for id in @selected_label_ids
        requests.push($.ajax({url: "/labels/#{id}", type: "delete"}));
      $.when.apply($, requests).then(() => @reload_table());

  merge_selected_labels: () =>
    new_label_name = @merge_labels_input.val();
    verification = verify_label_name(new_label_name);
    if verification != 'OK'
      alert(verification);
      return;

    selected_labels_count = @selected_label_ids.length;
    confirm_msg = I18n.t('labels.javascripts.merge_confirmation', {
      selected_labels_count: @selected_label_ids.length,
      new_merged_name: new_label_name
    })

    if (confirm(confirm_msg))
      $.ajax({
        url: "/labels/merge",
        type: "POST",
        data: {
          label_ids: @selected_label_ids,
          new_label_name: new_label_name
        },
        success: (response) => @reload_table();
      });

  recolor_selected_labels: () =>
    matched_color = @recolor_labels_input.val().match(/^#?([0-9A-Fa-f]{6})$/);
    if matched_color == null
      return;
    new_color = matched_color[1];

    confirm_msg = I18n.t('labels.javascripts.change_color_confirmation', {selected_labels_count: @selected_label_ids.length});

    if (confirm(confirm_msg))
      requests = []
      for id in @selected_label_ids
        requests.push(
          $.ajax({
            url: "/labels/#{id}",
            type: "PATCH",
            data: {label: {color: new_color}}
          })
        );
      $.when.apply($, requests).then(@reload_table);

ready = ->
  table_container = $('.labels-table-container');
  if table_container.length
    table = new LabelsTable(table_container);


$(document).on('turbo-migration:load', ready)
