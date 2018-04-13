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
  feedbackSubmitted: false,
  isUploading: false,
  classNames: ['feedback-form'],
  close: null, //passed-in action
  remarks: null,
  allowUploads: true,
  displayFeedbackForm: false,
  showSuccessCheckmark: true,

  screenshots: Ember.computed(() => []),

  feedbackService: Ember.inject.service('feedback'),

  actions: {
    submit() {
      if(this.get('isUploading')) { return; }

      this.get('feedbackService').sendFeedback(
        window.location.toString(),
        this.get('remarks'),
        this.get('screenshots')
      ).then(()=> {
        this.set('feedbackSubmitted', true);
      });
    },

    toggleForm() {
      this.toggleProperty('displayFeedbackForm');
    },

    uploadFinished(data, filename) {
      this.set('isUploading', false);
      this.get('screenshots').pushObject({
        url: data,
        filename: filename
      });
    },

    uploadStarted() {
      this.set('isUploading', true);
    },

    removeScreenshot(screenshot) {
      this.get('screenshots').removeObject(screenshot);
    }
  }
});
