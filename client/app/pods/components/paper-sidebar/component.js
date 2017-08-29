import Ember from 'ember';

const { computed: { filterBy, sort } } = Ember;

export default Ember.Component.extend({
  //paper: passed to component

  sidebarTasks: filterBy('paper.tasks', 'isSidebarTask', true),
  taskSorting: ['isSubmissionTask', 'assignedToMe:desc', 'phase.position', 'position'],
  sortedTasks: sort('sidebarTasks', 'taskSorting'),

  actions: {
    toggleSubmissionProcess(){
      this.attrs.toggleSubmissionProcess();
    },

    submitPaper(){
      this.attrs.showPaperSubmitOverlay();
    }
  }
});
