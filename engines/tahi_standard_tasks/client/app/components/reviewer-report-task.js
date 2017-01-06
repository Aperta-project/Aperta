import DecisionOwner from 'tahi/mixins/decision-owner';
import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend(DecisionOwner, {
  decisions: Ember.computed.readOnly('task.decisions'),

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
