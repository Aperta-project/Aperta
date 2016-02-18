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
        this.flash.displayMessage('error', 'At least one required Task remains incomplete. Please complete all required Tasks.');
      } else {
        this.set('isLoading', true);
        const taskId = this.get('model.id');
        const path = '/api/changes_for_author/' + taskId + '/submit_tech_check';

        this.get('restless').post(path).then(()=> {
          this.set('model.completed', true);
          this.send('saveModel');
          this.flash.displayMessage('success', this.successText());
        });
      }
    }
  }
});
