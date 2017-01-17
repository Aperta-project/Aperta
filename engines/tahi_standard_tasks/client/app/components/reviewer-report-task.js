import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  currentReviewerReport: Ember.computed.alias('task.reviewerReports.firstObject'),
  previousDecisions: Ember.computed.alias('task.paper.previousDecisions'),

  actions: {
    confirmSubmission() {
      this.set('submissionConfirmed', true);
    },

    cancelSubmission() {
      this.set('submissionConfirmed', false);
    },

    submitReport() {
      this.set('task.body.submitted', true);
      this.set('task.completed', true);
      this.get('task').save();
    }
  }
});
