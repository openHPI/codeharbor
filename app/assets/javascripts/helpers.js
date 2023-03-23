function get_filename_from_full_path(fullPath){
    var startIndex =
        fullPath.indexOf('\\') >= 0 ?
            fullPath.lastIndexOf('\\') :
            fullPath.lastIndexOf('/');
    var filename = fullPath.substring(startIndex);
    if (filename.indexOf('\\') == 0 || filename.indexOf('/') == 0) {
        filename = filename.substring(1);
    }
    return filename
}

/**
 * https://stackoverflow.com/questions/133925/javascript-post-request-like-a-form-submit
 * sends a request to the specified url from a form. this will change the window location.
 * @param {string} path the path to send the post request to
 * @param {object} params the parameters to add to the url
 * @param {string} [method=post] the method to use on the form
 */

function post(path, params, method='post') {
    const form = document.createElement('form');
    form.method = method;
    form.action = path;

    for (const key in params) {
        if (params.hasOwnProperty(key)) {
            const hiddenField = document.createElement('input');
            hiddenField.type = 'hidden';
            hiddenField.name = key;
            hiddenField.value = params[key];

            form.appendChild(hiddenField);
        }
    }

    document.body.appendChild(form);
    form.submit();
}
