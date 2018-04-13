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

import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  flash: Ember.inject.service(),
  activeEdit: Ember.computed('currentReviewerReport.adminEdits.[]', function() {
    return this.get('currentReviewerReport.adminEdits').findBy('active', true);
  }),
  noActiveAdminEdit: Ember.computed.not('currentReviewerReport.activeAdminEdit'),
  currentReviewerReport: Ember.computed.alias('task.reviewerReports.firstObject'),
  previousReviewerReports: Ember.computed('task.reviewerReports.@each.reviewerReport', 'task.paper.decision', function(){
    if (this.get('currentReviewerReport.decision.draft')) {
      return this.get('task.reviewerReports').slice(1);
    } else {
      return this.get('task.reviewerReports');
    }
  }),
  notesClass: Ember.computed('notesEmpty', function() {
    return this.get('notesEmpty') ? 'form-control error' : 'form-control';
  }),

  // this property is responsible for displaying (or not) the 'Make changes to this Task' button.
  // It can be modified later to depend on permissions
  taskStateToggleable: false,
  notFrontMatter: Ember.computed.not('frontMatter'),

  actions: {
    confirmSubmission() {
      this.set('submissionConfirmed', true);
    },

    cancelSubmission() {
      this.set('submissionConfirmed', false);
    },

    submitReport() {
      let report = this.get('currentReviewerReport');
      report.set('submitted', true);
      report.save().then(() => {
        this.set('task.completed', true);
        this.get('task').save();
        this.get('flash').displayRouteLevelMessage('success', 'Thank you for submitting your review.');
      });
    }
  }
});
