import Ember from 'ember';

export default Ember.Service.extend({

  notifyException: function(error, metadata = {}) {
    if (typeof Bugsnag !== 'undefined' && Bugsnag && Bugsnag.notifyException) {
      if (window.currentUserData && !Bugsnag.user) {
        Bugsnag.user = window.currentUserData.user;
      }
      Bugsnag.notifyException(error, metadata);
    } else {
      console.error( // eslint-disable-line no-console
        'Bugsnag not available, notifyException called with: ',
        'error:',
        error,
        ', metadata: ',
        metadata
      );
    }
  },

  notify: function(name, message, metadata={}, severity='warning') {
    if (typeof Bugsnag !== 'undefined' && Bugsnag && Bugsnag.notifyException) {
      if (window.currentUserData && !Bugsnag.user) {
        Bugsnag.user = window.currentUserData.user;
      }
      Bugsnag.notify(name, message, metadata, severity);
    } else {
      console.error( // eslint-disable-line no-console
        'Bugsnag not available, notify called with: ',
        'name: ',
        name,
        ', message:',
        message,
        ', metadata: ',
        metadata,
        ', severity: ',
        severity
      );
    }
  }
});
