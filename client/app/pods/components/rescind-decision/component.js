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

export default Ember.Component.extend({
  decision: null, // pass in an ember-data Decision
  isEditable: true, // pass in false to disable the rescind button

  busyWhile: null,

  // States:
  confirmingRescind: false,

  classNames: ['rescind-decision'],
  classNameBindings: ['hidden'],
  notDecision: Ember.computed.not('decision'),
  hidden: Ember.computed.or(
    'notDecision', 'decision.draft', 'decision.rescinded'),

  init() {
    this._super(...arguments);
  },

  actions: {
    cancel() {
      this.set('confirmingRescind', false);
    },

    confirmRescind() {
      this.set('confirmingRescind', true);
    },

    rescind() {
      this.set('confirmingRescind', false);
      const promise = this.get('decision').rescind().then(() => {
        Ember.tryInvoke(this, 'afterRescind');
      });
      if (typeof this.attrs.busyWhile === 'function') {
        this.attrs.busyWhile(promise);
      }
    }
  }
});
