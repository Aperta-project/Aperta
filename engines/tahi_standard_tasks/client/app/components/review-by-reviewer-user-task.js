import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  latestDecision: Ember.computed.alias('task.paper.latestDecision'),

  previousDecisions: Ember.computed('task.paper.decisions', function() {
    return this.get('task.previousDecisions');
  }),

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
