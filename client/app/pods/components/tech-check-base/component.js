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
import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  flash: Ember.inject.service(),
  restless: Ember.inject.service(),

  // Set in tech check task this inherits from base
  // bodyKey

  authoringMode: false,
  buttonText: 'Send Changes to Author',
  authorChangesLetter: null,
  successText: `The author has been notified via email that changes are
                needed. They will also see your message the next time they
                log in to see their manuscript.`,
  emailSending: false,

  emailNotAllowed: Ember.computed('task.paper.publishingState', function () {
    return this.get('emailSending') || !this.get('task.paper.isSubmitted');
  }),

  setLetter(callback) {
    const data = {};
    data[this.get('bodyKey')] = this.get('authorChangesLetter');
    this.set('task.body', data);

    this.get('task').save().then(()=> {
      this.get('flash').displayRouteLevelMessage(
        'success', 'Author Changes Letter has been Saved'
      );
      callback();
    });
  },

  actions: {
    setUiLetter() {
      return this.set(
        'authorChangesLetter', this.get('task.body.' + this.get('bodyKey'))
      );
    },

    activateAuthoringMode() {
      this.send('setUiLetter');
      return this.set('authoringMode', true);
    },

    saveLetterBody(contents) {
      this.set('authorChangesLetter', contents);
    },

    saveLetter() {
      return this.setLetter(function() {});
    },

    sendEmail() {
      this.set('emailSending', true);
      this.setLetter(()=> {
        const taskId = this.get('task.id');
        const path = `/api/tech_check/${taskId}/send_email`;
        this.get('restless').post(path).then(()=> {
          this.get('task.paper').reload();
          this.set('emailSending', false);
        });

        this.set('authoringMode', false);
        this.get('flash').displayRouteLevelMessage('success', this.get('successText'));
      });
    },

    setQuestionSelectedText() {
      const owner = this.get('task');

      const text = owner.get('nestedQuestions').sortBy('position').filter(function(q) {
        return !q.answerForOwner(owner).get('value') && q.get('additionalData');
      }).map(function(question) {
        return question.get('additionalData');
      }).join('<br><br>');

      this.set('authorChangesLetter', text);
    }
  }
});
