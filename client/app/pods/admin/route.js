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
import AuthorizedRoute from 'tahi/pods/authorized/route';


export default AuthorizedRoute.extend({
  beforeModel() {
    return Ember.$.ajax('/api/admin/journals/authorization');
  },

  setupController() {
    this._super(...arguments);
    this.setupPusher();
  },

  setupPusher() {
    let pusher = this.get('pusher');

    // This will bubble up to created and updated actions in the root
    // application route
    pusher.wire(this, 'private-admin', ['created', 'updated', 'destroyed']);
  },

  deactivate() {
    this.get('pusher').unwire(this, 'private-admin');
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method
    // to think we have `ember-pusher/bindings` mixed in
    return this.toString();
  },

  actions: {
    didTransition() {
      $('html').attr('screen', 'private-admin');
      return true;
    },

    willTransition() {
      $('html').attr('screen', '');
      return true;
    }
  }
});
