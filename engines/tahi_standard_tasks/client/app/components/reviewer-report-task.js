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
