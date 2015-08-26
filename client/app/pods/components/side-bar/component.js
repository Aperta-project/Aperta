import Ember from 'ember';

export default Ember.Component.extend({
  tagName:     'aside',
  classNames:  ['sidebar'],
  taskSorting: ['phase.position', 'position'],
  sortedMetadataTasks: Ember.computed.sort('metadataTasks', 'taskSorting'),
  sortedAssignedTasks: Ember.computed.sort('assignedTasks', 'taskSorting'),

  actions: {

    viewCard(task){
      this.sendAction('viewCard', task)
    },

    submitPaper(){
      if (this.get('paper.allSubmissionTasksCompleted')) {
        this.get('paper').save();
        this.sendAction('showConfirmSubmitOverlay');
      }
    }
  }
});
