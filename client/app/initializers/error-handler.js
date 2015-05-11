import Ember from 'ember';
import ENV from 'tahi/config/environment';

export default {
  name: 'errorHandler',
  after: 'flashMessages',
  initialize(container, application) {
    let flash = container.lookup('flashMessages:main');

    let logError = function(msg) {
      let e = new Error(msg);
      if (e.message) { console.log(e.message); }
      return console.log(e.stack || e.message);
    };

    container.register('logError:main', logError, {
      instantiate: false
    });

    application.inject('route', 'logError', 'logError:main');

    // The global error handler for internal ember errors
    Ember.onerror = function(error) {
      if (ENV.environment === 'production') {
        if (Bugsnag && Bugsnag.notifyException) {
          return Bugsnag.notifyException(error, "Uncaught Ember Error");
        }
      } else {
        flash.displayMessage('error', error);
        logError('\n' + error.message + '\n' + error.stack + '\n');
        throw error;
      }
    };

    // Server response error handler
    $(document).ajaxError(function(event, jqXHR, ajaxSettings, thrownError) {
      let type       = ajaxSettings.type;
      let url        = ajaxSettings.url;
      let status     = jqXHR.status;
      let statusText = jqXHR.statusText;

      // don't blow up in case of a 403 from rails
      if (status === 403) { return; }
      // ember data should handle these errors.
      if (status === 422) { return; }
      // session invalid, redirect to sign in
      if (status === 401) { return document.location.href = '/users/sign_in'; }

      let msg = `Error with ${type} request to ${url}. Server returned ${status}: ${statusText}. ${thrownError}`;
      logError(msg);
      // TODO: Remove this condidition when we switch to run loop respecting http mocks
      if (!Ember.testing) { return flash.displayMessage('error', msg); }
    });
  }
};
