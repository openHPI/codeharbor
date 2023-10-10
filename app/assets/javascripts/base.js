Array.prototype.includes = function(element) {
  return this.indexOf(element) !== -1;
};

const ANIMATION_DURATION = 500;

$.isController = function(name) {
  return $('div[data-controller="' + name + '"]').isPresent();
};

$.fn.isPresent = function() {
  return this.length > 0;
};

$.fn.scrollTo = function(selector) {
  $(this).animate({
    scrollTop: $(document.querySelector(selector)).offset().top - $(this).offset().top + $(this).scrollTop()
  }, ANIMATION_DURATION);
};

$(document).on('turbolinks:load', function() {
    // Update all CSRF tokens on the page to reduce InvalidAuthenticityToken errors
    // See https://github.com/rails/jquery-ujs/issues/456 for details
    $.rails.refreshCSRFTokens();

    // Set locale for all JavaScript functions
    const htmlTag = $('html')
    I18n.defaultLocale = htmlTag.data('default-locale');
    I18n.locale = htmlTag.attr('lang');

    // Enable all tooltips
    $('[data-bs-toggle="tooltip"]').tooltip();

    // Ensure that the tab button will be in active (selected) state for each page that has 'option' query (e.g. groups or messages page)
    $('#' + $('#option').val()).addClass('selected');
});
