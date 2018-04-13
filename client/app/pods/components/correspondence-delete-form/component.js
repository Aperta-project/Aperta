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
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  close: null,
  restless: Ember.inject.service(),
  store: Ember.inject.service(),
  reason: null,
  correspondenceId: Ember.computed.reads('model.id'),
  paperId: Ember.computed.reads('model.paper.id'),
  reasonClass: Ember.computed('reasonEmpty', function() {
    return this.get('reasonEmpty') ? 'form-control error' : 'form-control';
  }),


  actions: {
    delete() {
      let reason = this.get('reason');
      if(Ember.isEmpty(reason)) {
        this.set('reasonEmpty', true);
      } else {
        let model = this.get('model');
        model.set('status', 'deleted');
        model.set('additionalContext', {delete_reason: reason});
        model.save().then(() => {
          this.sendAction('close');
        });
      }
    },
    clearReasonError() {
      this.set('reasonEmpty', false);
    }
  }
});
