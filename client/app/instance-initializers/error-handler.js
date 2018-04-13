/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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

      let msg = `Error with ${type} request to ${url}. Server returned ${status}: ${statusText}. ${thrownError}`;
      logError(new Error(msg));
      // TODO: Remove this condidition when we switch to run loop respecting http mocks
      if (!Ember.testing) { flash.displayRouteLevelMessage('error', msg); }
    });
  }
};
