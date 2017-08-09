import Ember from 'ember';

const { computed: { filterBy, sort } } = Ember;

export default Ember.Component.extend({
  //paper: passed to component

  sidebarTasks: filterBy('paper.tasks', 'isSidebarTask', true),
  taskSorting: ['position'],
  phaseSorting: ['phase.position'],
  // it seems sorting separately produces better results than lumping all the sort criteria together
  sortedTasks: sort('sidebarTasks', 'taskSorting'),
  sortedPhases: sort('sortedTasks', 'phaseSorting'),

  actions: {
    toggleSubmissionProcess(){
      this.attrs.toggleSubmissionProcess();
    },

    submitPaper(){
      this.attrs.showPaperSubmitOverlay();
    }
  }
});
