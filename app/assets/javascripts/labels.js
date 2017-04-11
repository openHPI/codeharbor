/**
 * Created by adrian on 4/11/17.
 */
var ready;
ready =  function() {
    $('.my-tag').select2({
        tags: true,
        width: '100%',
        tokenSeparators: [","," "],
        createSearchChoice: function(term, data) {
            if ($(data).filter(function() {
                    return this.text.localeCompare(term) === 0;
                }).length === 0) {
                return {
                    id: term,
                    text: term
                };
            }
        },
        multiple: true,
        maximumSelectionSize: 5,
        formatSelectionTooBig: function (limit) {
            return 'You can only add 5 topics'

        },
        ajax: {
            dataType: 'json',
            url: '/labels/search.json',
            processResults: function (data) {
                return {
                    results: $.map(data, function(obj) {
                        return { id: obj.name, text: obj.name };
                    })
                };
            }
        }
    });
};
$(document).ready(ready);
$(document).on('page:load', ready);
