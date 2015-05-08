export default {
  name: 'csrf',
  after: 'currentUser',
  initialize: function(container, application) {
    let token = $('meta[name="csrf-token"]').attr('content');
    $.ajaxPrefilter(function(options, originalOptions, xhr) {
      return xhr.setRequestHeader('X-CSRF-Token', token);
    });
  }
};
