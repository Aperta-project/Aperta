export default {
  name: 'csrf',
  after: 'currentUser',
  initialize() {
    let token = $('meta[name="csrf-token"]').attr('content');
    $.ajaxPrefilter(function(options, originalOptions, xhr) {
      return xhr.setRequestHeader('X-CSRF-Token', token);
    });
  }
};
