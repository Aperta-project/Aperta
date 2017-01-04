import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  latestDecision: Ember.computed.alias('task.paper.latestDecision'),

  registeredDecisionsDescending: Ember.computed('task.paper.registeredDecisionsAscending.[]', function() {
    return this.get('task.paper.registeredDecisionsAscending').reverseObjects();
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
