import Ember from 'ember';

const { computed } = Ember;
const {
  alias,
  and,
  equal,
  filterBy,
  not,
  or,
  setDiff,
  sort
} = computed;

export default Ember.Component.extend({
  //paper: passed to component
  taskSorting: ['phase.position', 'position'],

  getsGradualEngagementToggle: computed(
    'paper.publishingState', 'paper.gradualEngagement', function(){
      const p = this.get('paper');
      const state = p.get('publishingState');
      const states = [
        'unsubmitted',
        'initially_submitted',
        'invited_for_full_submission'
      ];
      return (p.get('gradualEngagement') && _.contains(states, state));
    }
  ),

  tasks: alias('paper.tasks'),
  isUnsubmitted: equal('paper.publishingState', 'unsubmitted'),
  isInRevision: equal('paper.publishingState', 'in_revision'),
  isInvitedForFullSubmission: equal(
    'paper.publishingState',
    'invited_for_full_submission'
  ),
  isSubmitted: equal('paper.publishingState', 'submitted'),
  sortedAssignedTasks: sort('assignedTasks', 'taskSorting'),
  sortedMetadataTasks: sort('metadataTasks', 'taskSorting'),
  sortedSubmissionTasks: sort('submissionTasks', 'taskSorting'),
  assignedTasks: setDiff('currentUserTasks', 'submissionTasks'),
  metadataTasks: filterBy('tasks', 'isMetadataTask', true),
  submissionTasks: filterBy('tasks', 'isSubmissionTask', true),
  submittableState: or(
    'isUnsubmitted',
    'isInRevision',
    'isInvitedForFullSubmission'
  ),
  readyToSubmit: and('submittableState', 'allSubmissionTasksCompleted'),
  isPendingTasks: not('allSubmissionTasksCompleted'),
  preSubmission: and('submittableState', 'isPendingTasks'),
  currentUserTasks: filterBy('paper.tasks', 'assignedToMe'),

  allSubmissionTasksCompleted: computed(
    'submissionTasks.@each.completed',
    function() {
      return this.get('submissionTasks').isEvery('completed', true);
    }
  ),

  actions: {
    toggleSubmissionProcess(){
      this.attrs.toggleSubmissionProcess();
    },

    submitPaper(){
      if (this.get('allSubmissionTasksCompleted')) {
        this.get('paper').save();
        this.attrs.showPaperSubmitOverlay();
      }
    }
  }
});
