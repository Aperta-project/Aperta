import Ember from 'ember';
import ENV from 'tahi/config/environment';

export default {
  name: 'errorHandler',

  initialize(instance) {
    let flash    = instance.lookup('service:flash');
    let logError = instance.lookup('logError:main');
    let bugsnag  = instance.lookup('service:bugsnag');

    // The global error handler for internal ember errors.
    // In production and staging send the error to bugsnag.
    // In development show the error in the flash, log to
    // the console and throw again.
    if (!Ember.testing) {
      Ember.onerror = function(error) {
        logError(error);
        if (ENV.environment !== 'development') {
          bugsnag.notifyException(error);
        } else {
          flash.displayRouteLevelMessage('error', error);
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
      // a 404 could happen when pusher reloads, so either handle
      // it at the call site or let ember data pick it up.
      if (status === 404) { return; }
      // ember data should handle these errors.
      if (status === 422) { return; }
      // session invalid, redirect to sign in
      if (status === 401) { return document.location.href = '/users/sign_in'; }
      // health service handles its own alert messages, so we just return
      if ((status === 500 || status === 503 || status === 307) && url.match(/^\/health/) ) { return; }

      let msg = `Error with ${type} request to ${url}. Server returned ${status}: ${statusText}. ${thrownError}`;
      logError(new Error(msg));
      // TODO: Remove this condidition when we switch to run loop respecting http mocks
      if (!Ember.testing) { flash.displayRouteLevelMessage('error', msg); }
    });
  }
};
