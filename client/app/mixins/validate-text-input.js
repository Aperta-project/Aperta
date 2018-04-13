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

export default Ember.Mixin.create({
  answerProxy: null,
  hideError: true,

  init() {
    // Answerproxy avoids having the input 2-way bind with answer.value
    this._super(...arguments);
    this.set('answerProxy', this.get('answer.value'));
  },

  actions: {
    valueChanged(newValue) {
      //in effect, this makes `answerProxy` a computed on answer.value
      this.set('answerProxy', newValue);
      // Hide error messages if field is blank
      if (Ember.isBlank(newValue) || newValue === '<p></p>') this.set('hideError', true);

      let action = this.get('valueChanged');
      if (action) { action(newValue); }
    },

    displayErrors() {
      // All persistence done on input. Show errors once user focuses out.
      this.set('hideError', false);
    }
  }
});
