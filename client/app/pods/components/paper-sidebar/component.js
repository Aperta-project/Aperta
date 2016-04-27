import Ember from 'ember';

const { computed } = Ember;
const {
  alias,
  filterBy,
  setDiff,
  sort
} = computed;

export default Ember.Component.extend({
  //paper: passed to component
  taskSorting: ['phase.position', 'position'],

  tasks: alias('paper.tasks'),

  currentUserTasks: filterBy('paper.tasks', 'assignedToMe'),
  assignedTasks: setDiff('currentUserTasks', 'submissionTasks'),
  sortedAssignedTasks: sort('assignedTasks', 'taskSorting'),

  actions: {
    toggleSubmissionProcess(){
      this.attrs.toggleSubmissionProcess();
    },

    submitPaper(){
      this.get('paper').save();
      this.attrs.showPaperSubmitOverlay();
    }
  }
});
