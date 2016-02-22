import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  restless: Ember.inject.service(),
  flash: Ember.inject.service(),
  submissionTasks: Ember.computed.filterBy('tasks', 'isSubmissionTask', true),

  successText() {
    const journalName = this.get('task.paper.journal.name');
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
        const taskId = this.get('task.id');
        const path = '/api/changes_for_author/' + taskId + '/submit_tech_check';

        this.get('restless').post(path).then(()=> {
          this.set('task.completed', true);
          this.send('save');
          this.get('flash').displayMessage('success', this.successText());
        });
      }
    }
  }
});
