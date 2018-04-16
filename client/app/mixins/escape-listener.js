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

const ESC_KEY = 27;
const notEscapeKey = function(e) {
  return e.keyCode !== ESC_KEY || e.which !== ESC_KEY;
};

const ofType = 'input, textarea, [contenteditable=true], .select-box-element';
const focusedInField = function(e) {
  return Ember.$(e.target).is(ofType);
};

export default Ember.Mixin.create({
  escapeKeyAction: 'close',

  eventName() {
    return 'keyup.' + this.get('elementId');
  },

  setupKeyup: Ember.on('didInsertElement', function() {
    Ember.$('body').on(this.eventName(), (e)=> {
      if (notEscapeKey(e))   { return; }
      if (focusedInField(e)) { return; }
      this.send(this.get('escapeKeyAction'));
    });
  }),

  tearDownKeyup: Ember.on('willDestroyElement', function() {
    Ember.$('body').off(this.eventName());
  })
});
