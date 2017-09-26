import Ember from 'ember';

const { computed: { filter, sort } } = Ember;

export default Ember.Component.extend({
  //paper: passed to component

  sidebarTasks: filter('paper.tasks', function(task) {
    return task.get('isSidebarTask') && task.get('viewable');
  }),

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
