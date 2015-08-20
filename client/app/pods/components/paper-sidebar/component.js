import Ember from 'ember';

export default Ember.Component.extend({
  tagName:     'aside',
  classNames:  ['sidebar'],
  taskSorting: ['phase.position', 'position'],
  sortedMetadataTasks: Ember.computed.sort('metadataTasks', 'taskSorting'),
  sortedAssignedTasks: Ember.computed.sort('assignedTasks', 'taskSorting'),
  metadataTasks: Ember.computed.filterBy('paper.tasks', 'isMetadataTask', true),
  assignedTasks: Ember.computed.setDiff('currentUserTasks', 'metadataTasks'),

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
