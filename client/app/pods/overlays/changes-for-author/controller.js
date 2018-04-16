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
import TaskController from 'tahi/pods/paper/task/controller';

export default TaskController.extend({
  restless: Ember.inject.service(),
  submissionTasks: Ember.computed.filterBy('tasks', 'isSubmissionTask', true),

  successText: function() {
    let journalName = this.get('model.paper.journal.name');
    return "Thank you. Your changes have been sent to " + journalName + ".";
  },

  allSubmissionTasksCompleted: Ember.computed('submissionTasks.@each.completed', function() {
    return this.get('submissionTasks').isEvery('completed', true);
  }),

  actions: {
    submitTechChanges() {
      if (this.get('isNotEditable')) { return; }
      if (!this.get('allSubmissionTasksCompleted')) {
        this.flash.displayRouteLevelMessage('error', 'At least one required Task remains incomplete. Please complete all required Tasks.');
      } else {
        this.set('isLoading', true);
        const taskId = this.get('model.id');
        const path = '/api/changes_for_author/' + taskId + '/submit_tech_check';

        this.get('restless').post(path).then(()=> {
          this.set('model.completed', true);
          this.send('saveModel');
          this.flash.displayRouteLevelMessage('success', this.successText());
        });
      }
    }
  }
});
