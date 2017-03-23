import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  currentReviewerReport: Ember.computed.alias('task.reviewerReports.firstObject'),
  previousReviewerReports: Ember.computed('task.reviewerReports.@each.reviewerReport', function(){
    if (this.get('currentReviewerReport.decision.draft')) {
      return this.get('task.reviewerReports').slice(1);
    } else {
      return this.get('task.reviewerReports');
    }
  }),

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
      });
    }
  }
});
