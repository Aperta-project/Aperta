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

/**
* A full-overlay-verification is a confirmation dialog that covers a
* whole task overlay; it's big, it's green, and it's got centered text
* and two buttons. Pass in a question (string), a confirm action, and a
* cancel action.
*/

import Ember from 'ember';

const ESC_KEY = 27;
const escapeKey = function(e) {
  return e.keyCode === ESC_KEY || e.which === ESC_KEY;
};

export default Ember.Component.extend({
  classNames: ['full-overlay-verification'],

  confirmText: 'Yes',
  cancelText: 'Cancel',
  cancel: null, // action run on cancel
  confirm: null, // action run on confirm

  eventName() {
    return 'keyup.' + this.get('elementId');
  },

  setupEscapeListener: Ember.on('didInsertElement', function() {
    Ember.$('body').on(this.eventName(), (e)=> {
      if (escapeKey(e)) {
        this.sendAction('cancel');
      }
    });
  }),

  tearDownEscapeListener: Ember.on('willDestroyElement', function() {
    Ember.$('body').off(this.eventName());
  })

});
