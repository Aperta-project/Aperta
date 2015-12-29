export default function() {
  var error;

  const headers = $('.column-header');
  if (!headers.length) { return; }

  let max = null;
  const wrappers = headers.find('.column-title-wrapper');
  wrappers.css('height', '');

  try {
    max = Math.max.apply(Math, wrappers.map(function() {
      return $(this).outerHeight();
    }));
  } catch (_error) {
    error = _error;
    max = 20;
  }

  wrappers.css('height', max);
  $('.column-content').css('top', headers.first().outerHeight());
}
