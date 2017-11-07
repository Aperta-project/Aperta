import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  flash: Ember.inject.service(),
  currentReviewerReport: Ember.computed.alias('task.reviewerReports.firstObject'),
  previousReviewerReports: Ember.computed('task.reviewerReports.@each.reviewerReport', 'task.paper.decision', function(){
    if (this.get('currentReviewerReport.decision.draft')) {
      return this.get('task.reviewerReports').slice(1);
    } else {
      return this.get('task.reviewerReports');
    }
  }),
  // this property is responsible for displaying (or not) the 'Make changes to this Task' button.
  // It can be modified later to depend on permissions
  taskStateToggleable: false,
  editing: false,
  notEditing: Ember.computed.not('editing'),

  changedAnswers: Ember.computed('currentReviewerReport.nestedQuestionAnswers.[]', function() {
    return this.get('currentReviewerReport.nestedQuestionAnswers')
      .filter(answer => answer && answer.changedAttributes().value);
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
        this.get('flash').displayRouteLevelMessage('success', 'Thank you for submitting your review.');
      });
    },

    // Admin functions to modify a submitted report
    editReport() {
      this.set('currentReviewerReport.delaySave', true);
      this.set('editing', true);
    },

    saveEdits() {
      this.set('editing', false);
      this.get('changedAnswers').forEach(answer => answer.save());
      this.set('currentReviewerReport.delaySave', false);
    },

    cancelEdits() {
      this.set('editing', false);
      this.get('changedAnswers').forEach(answer => answer.rollbackAttributes());
      this.set('currentReviewerReport.delaySave', false);
    }
  }
});
