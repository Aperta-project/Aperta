import Ember from 'ember';

export default Ember.Service.extend({
  notifyException: function(error, name, metadata = {}, severity = 'error') {
    if (typeof Bugsnag !== 'undefined' && Bugsnag && Bugsnag.notifyException) {
      if (window.currentUserData && !Bugsnag.user) {
        Bugsnag.user = window.currentUserData.user;
      }
      Bugsnag.notifyException(error, name, metadata, severity);
    } else {
      console.error(
        'Bugsnag not available, notifyException called with: ',
        'error:',
        error,
        'name: ',
        name,
        'metadata: ',
        metadata
      );
    }
  },

  notifyUploadError: function(error, metadata={}) {
    this.notifyException(error, 'File Upload Error', metadata);
  }
});
