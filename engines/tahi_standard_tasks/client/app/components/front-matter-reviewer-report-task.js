import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  draftDecision: Ember.computed.alias('task.paper.draftDecision'),

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
