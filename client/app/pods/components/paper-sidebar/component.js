import Ember from 'ember';


export default Ember.Component.extend({
  //paper: passed to component
  tagName:     'aside',
  classNames:  ['sidebar'],
  taskSorting: ['phase.position', 'position'],
  tasks: Ember.computed.alias('paper.tasks'),
  isUnsubmitted: Ember.computed.equal('paper.publishingState', 'unsubmitted'),
  isInRevision: Ember.computed.equal('paper.publishingState', 'in_revision'),
  isInvitedForFullSubmission: Ember.computed.equal('paper.publishingState', 'invited_for_full_submission'),
  isSubmitted: Ember.computed.equal('paper.publishingState', 'submitted'),
  sortedMetadataTasks: Ember.computed.sort('metadataTasks', 'taskSorting'),
  sortedAssignedTasks: Ember.computed.sort('assignedTasks', 'taskSorting'),
  metadataTasks: Ember.computed.filterBy('tasks', 'isMetadataTask', true),
  assignedTasks: Ember.computed.setDiff('currentUserTasks', 'metadataTasks'),
  submissionTasks: Ember.computed.filterBy('tasks', 'isSubmissionTask', true),
  submittableState: Ember.computed.or('isUnsubmitted', 'isInRevision', 'isInvitedForFullSubmission'),
  readyToSubmit: Ember.computed.and('submittableState', 'allSubmissionTasksCompleted'),
  isPendingTasks: Ember.computed.not('allSubmissionTasksCompleted'),
  preSubmission: Ember.computed.and('submittableState', 'isPendingTasks'),
  currentUserTasks: Ember.computed.filterBy('paper.tasks', 'assignedToMe'),

  allSubmissionTasksCompleted: Ember.computed('submissionTasks.@each.completed', function() {
    return this.get('submissionTasks').isEvery('completed', true);
  }),

  getsGradualEngagementToggle: Ember.computed('paper.publishingState', function(){
    let states = ['unsubmitted', 'initially_submitted', 'invited_for_full_submission'];
    let p = this.get('paper');
    let state = p.get('publishingState');
    return (p.get('gradualEngagement') && _.contains(states, state));
  }),

  actions: {

    viewCard(task){
      this.sendAction('viewCard', task);
    },

    toggleSubmissionProcess(){
      $('#submission-process').slideToggle(300)
    },

    submitPaper(){
      if (this.get('allSubmissionTasksCompleted')) {
        this.get('paper').save();
        this.sendAction('showConfirmSubmitOverlay');
      }
    }
  }
});
