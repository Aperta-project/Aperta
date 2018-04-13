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
  classNames: ['autosave'],
  modelIsSaving: false,
  isSaving: false,
  showCheckMark: false,

  setup: Ember.on('init', function() {
    this.set('isSaving', this.get('modelIsSaving'));
  }),

  modelIsSavingDidChange: Ember.observer('modelIsSaving', function() {
    if (this.get('modelIsSaving')) {
      this.set('isSaving', true);
    } else {
      Ember.run.later(this, function() {
        this.set('isSaving', false);
        this.set('showCheckMark', true);
        this.hideCheckMarkAfterDelay();
      }, 1000);
    }
  }),

  hideCheckMarkAfterDelay() {
    Ember.run.later(this, function() {
      this.hideCheckMark();
    }, 2000);
  },

  hideCheckMark() {
    this.set('showCheckMark', false);
  }
});
