import Ember from 'ember';

const { computed } = Ember;
const { alias, equal, sort, filterBy, setDiff, or, and, not } = computed;

export default Ember.Component.extend({
  taskSorting: ['phase.position', 'position'],
  tasks: alias('paper.tasks'),
  isUnsubmitted: equal('paper.publishingState', 'unsubmitted'),
  isInRevision: equal('paper.publishingState', 'in_revision'),
  isSubmitted: equal('paper.publishingState', 'submitted'),
  sortedMetadataTasks: sort('metadataTasks', 'taskSorting'),
  sortedAssignedTasks: sort('assignedTasks', 'taskSorting'),
  metadataTasks: filterBy('tasks', 'isMetadataTask', true),
  assignedTasks: setDiff('currentUserTasks', 'metadataTasks'),
  submissionTasks: filterBy('tasks', 'isSubmissionTask', true),
  submittableState: or('isUnsubmitted', 'isInRevision'),
  readyToSubmit: and('submittableState', 'allSubmissionTasksCompleted'),
  isPendingTasks: not('allSubmissionTasksCompleted'),
  preSubmission: and('submittableState', 'isPendingTasks'),
  allSubmissionTasksCompleted: computed('submissionTasks.@each.completed', function() {
    return this.get('submissionTasks').isEvery('completed', true);
  }),

  currentUserTasks: filterBy('paper.tasks', 'assignedToMe'),

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
