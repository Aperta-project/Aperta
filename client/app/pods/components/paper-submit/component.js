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
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  flash: Ember.inject.service(),
  restless: Ember.inject.service(),
  paperSubmitted: false,
  previousPublishingState: null,
  isFirstFullSubmission: Ember.computed.equal(
    'previousPublishingState', 'invited_for_full_submission'
  ),

  recordPreviousPublishingState: function(){
    this.set('previousPublishingState', this.get('model.publishingState'));
  },

  actions: {
    submit() {
      this.recordPreviousPublishingState();
      this.get('restless').putUpdate(this.get('model'), '/submit').then(()=> {
        this.set('paperSubmitted', true);
      }, (arg)=> {
        const status = arg.status;
        const model  = arg.model;
        let message;
        switch (status) {
          case 422:
            const errors = model.get('errors.messages');
            message =  errors + ' You should probably reload.';
            break;
          case 403:
            message = 'You weren\'t authorized to do that';
            break;
          default:
            message = 'There was a problem saving. Please reload.';
        }

        this.get('flash').displayRouteLevelMessage('error', message);
      });
    },

    close() {
      this.attrs.close();
    }
  }
});
