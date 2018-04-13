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

export default Ember.Route.extend({
  can: Ember.inject.service('can'),
  restless: Ember.inject.service('restless'),

  handleUnauthorizedRequest(transition, error) {
    let errorMessage = error || "You don't have access to that content";
    transition.abort();
    this.transitionTo('dashboard').then(()=> {
      this.flash.displayRouteLevelMessage('error', errorMessage);
    });
  },

  actions: {
    error(response, transition) {
      if (!response) {
        this.handleUnauthorizedRequest(transition);
      }
      if (Ember.isArray(response.errors)) {
        let status = response.errors[0].status;
        // use == instead of === to coerce "404" into 404
        if ( status == 404 || status == 403 ) {
          let errorMsg = response.errors[0].detail;
          this.handleUnauthorizedRequest(transition, errorMsg);
        }
      } else if (response.status == 403) {
        this.handleUnauthorizedRequest(transition);
      }
      return true;
    },
    _pusherEventsId() {
      // needed for the `wire` and `unwire` method to think we have `ember-pusher/bindings` mixed in
      return this.toString();
    }
  }
});
