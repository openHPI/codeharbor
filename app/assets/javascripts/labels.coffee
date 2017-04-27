ready = ->
  $('.my-tag').select2
    tags: true
    width: '100%'
    tokenSeparators: [
      ','
      ' '
    ]
    createSearchChoice: (term, data) ->
      if $(data).filter((->
        @text.localeCompare(term) == 0
      )).length == 0
        return {
          id: term
          text: term
        }
      return
    multiple: true
    maximumSelectionSize: 5
    formatSelectionTooBig: (limit) ->
      'You can only add 5 topics'
    ajax:
      dataType: 'json'
      url: '/labels/search.json'
      processResults: (data) ->
        { results: $.map(data, (obj) ->
          {
            id: obj.name
            text: obj.name
          }
        ) }
  return

$(document).ready ready
$(document).on 'page:load', ready