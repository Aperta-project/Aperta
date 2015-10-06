import Ember from 'ember';

export default Ember.Component.extend({
  tagName:     'aside',
  classNames:  ['sidebar'],
  taskSorting: ['phase.position', 'position'],
  tasks: Ember.computed.alias('paper.tasks'),
  isUnsubmitted: Ember.computed.equal('paper.publishingState', 'unsubmitted'),
  isInRevision: Ember.computed.equal('paper.publishingState', 'in_revision'),
  isSubmitted: Ember.computed.equal('paper.publishingState', 'submitted'),
  sortedMetadataTasks: Ember.computed.sort('metadataTasks', 'taskSorting'),
  sortedAssignedTasks: Ember.computed.sort('assignedTasks', 'taskSorting'),
  metadataTasks: Ember.computed.filterBy('tasks', 'isMetadataTask', true),
  assignedTasks: Ember.computed.setDiff('currentUserTasks', 'metadataTasks'),
  submissionTasks: Ember.computed.filterBy('tasks', 'isSubmissionTask', true),
  submittableState: Ember.computed.or('isUnsubmitted', 'isInRevision'),
  readyToSubmit: Ember.computed.and('submittableState', 'allSubmissionTasksCompleted'),
  isPendingTasks: Ember.computed.not('allSubmissionTasksCompleted'),
  preSubmission: Ember.computed.and('submittableState', 'isPendingTasks'),

  allSubmissionTasksCompleted: Ember.computed('submissionTasks.@each.completed', function() {
    return this.get('submissionTasks').everyProperty('completed', true);
  }),

  currentUserTasks: Ember.computed.filter('paper.tasks', function(task) {
    return task.get('participations').mapBy('user').contains(this.get('user'));
  }),

  actions: {

    viewCard(task){
      this.sendAction('viewCard', task);
    },

    submitPaper(){
      if (this.get('allSubmissionTasksCompleted')) {
        this.get('paper').save();
        this.sendAction('showConfirmSubmitOverlay');
      }
    }
  }
});
