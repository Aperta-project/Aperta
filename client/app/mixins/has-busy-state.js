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

/**
  Adds a `busyWhile` method to a class that is used to set a `busy` attribute on
  an instance while a promise is running.

  Example usage:

  ```javascript
  Component.extend(HasBusyStateMixin, {
    classNameBindings: ['busy:show-spinner'],

    actions: {
      saving() {
        this.busyWhile(model.save());
      },
    }
  }
  ```
  @extends Ember.Mixin
  @class HasBusyStateMixin
*/
export default Ember.Mixin.create({
  busy: false,

  /**
    Sets `busy` attribute to `true`, then returns a promise that will set the
    `busy` attribute to false after the provided `promise` param resolves.

    @method busyWhile
    @param {Ember.RSVP.Promise} promise A promise during the execution of which
      the `busy` attribute will be set to true.
    @return {Ember.RSVP.Promise} A promise that resolves after the `busy` attribute has been set to `false`
  */
  busyWhile(promise) {
    let setBusy = new Ember.RSVP.Promise((resolve) => {
      this.set('busy', true);
      resolve();
    });
    return Ember.RSVP.all([setBusy, promise]).finally(()=> { this.set('busy', false); } );
  }
});
