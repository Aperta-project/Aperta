import Ember from 'ember';

export default Ember.Component.extend({
  tagName:     'aside',
  classNames:  ['sidebar'],
  taskSorting: ['phase.position', 'position'],
  sortedMetadataTasks: Ember.computed.sort('metadataTasks', 'taskSorting'),
  sortedAssignedTasks: Ember.computed.sort('assignedTasks', 'taskSorting'),
  metadataTasks: Ember.computed.filterBy('paper.tasks', 'isMetadataTask', true),
  assignedTasks: Ember.computed.setDiff('currentUserTasks', 'metadataTasks'),

  allSubmissionTasksCompleted: Ember.computed('allSubmissionTasks.@each.completed', function() {
    return this.get('allSubmissionTasks').everyProperty('completed', true);
  }),

  submittableState: Ember.computed('publishingState', function() {
    let state = this.get('publishingState');
    return state === 'unsubmitted' || state === 'in_revision';
  }),

  preSubmission: Ember.computed('submittableState', 'allSubmissionTasksCompleted', function() {
    return (this.get('submittableState') &&
            !this.get('allSubmissionTasksCompleted'));
  }),

  allSubmissionTasks: Ember.computed('tasks.content.@each.isSubmissionTask', function() {
    return this.get('tasks').filterBy('isSubmissionTask');
  }),

  readyToSubmit: Ember.computed('submittableState', 'allSubmissionTasksCompleted', function() {
    return (this.get('submittableState') &&
            this.get('allSubmissionTasksCompleted'));
  }),

  postSubmission: Ember.computed.not('submittableState'),

  currentUserTasks: Ember.computed.filter('paper.tasks', function(task) {
    return task.get('participations').mapBy('user').contains(this.get('user'));
  }),

  actions: {

    viewCard(task){
      this.sendAction('viewCard', task);
    },

    submitPaper(){
      if (this.get('paper.allSubmissionTasksCompleted')) {
        this.get('paper').save();
        this.sendAction('showConfirmSubmitOverlay');
      }
    }
  }
});
