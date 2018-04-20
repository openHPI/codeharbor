ready = ->
  $('.my-tag').select2
    tags: true
    multiple: true
    minimumInputLength: 1
    createTag: (params) ->
      term = $.trim(params.term)
      if term == ''
        return null
      {
        id: term
        text: term
        newTag: true
      }
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
    maximumSelectionLength: 5
    formatSelectionTooBig: (limit) ->
      'You can only add 5 labels'
      tags: false
  return

$(document).on 'turbolinks:load', ready