import Ember from 'ember';
import ENV from 'tahi/config/environment';

export default {
  name: 'errorHandler',

  initialize(instance) {
    let flash    = instance.container.lookup('service:flash');
    let logError = instance.container.lookup('logError:main');

    // The global error handler for internal ember errors
    if (!Ember.testing) {
      Ember.onerror = function(error) {
        if (ENV.environment === 'production') {
          if (typeof Bugsnag !== 'undefined' && Bugsnag && Bugsnag.notifyException) {
            if (error.errors && error.errors.length) {
              let meta = {
                metaData: {
                  error_info: error.errors[0]
                }
              };
              Bugsnag.notifyException(error, 'Uncaught Ember Error', meta);
            } else {
              Bugsnag.notifyException(error, 'Uncaught Ember Error');
            }
          }
        } else {
          flash.displayMessage('error', error);
          logError(error);
          throw error;
        }
      };
    }

    // Server response error handler
    $(document).ajaxError(function(event, jqXHR, ajaxSettings, thrownError) {
      let type       = ajaxSettings.type;
      let url        = ajaxSettings.url;
      let status     = jqXHR.status;
      let statusText = jqXHR.statusText;

      // don't blow up if xhr was aborted
      if (statusText === 'abort') { return; }
      // don't blow up in case of a 403 from rails
      if (status === 403) { return; }
      // ember data should handle these errors.
      if (status === 422) { return; }
      // session invalid, redirect to sign in
      if (status === 401) { return document.location.href = '/users/sign_in'; }

      let msg = `Error with ${type} request to ${url}. Server returned ${status}: ${statusText}. ${thrownError}`;
      logError(new Error(msg));
      // TODO: Remove this condidition when we switch to run loop respecting http mocks
      if (!Ember.testing) { flash.displayMessage('error', msg); }
    });
  }
};
