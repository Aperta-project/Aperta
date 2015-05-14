import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen choose-new-card-type-overlay',
  taskTypeSort: ['title:asc'],
  taskType: null,
  sortedTaskTypes: Ember.computed.sort('journalTaskTypes', 'taskTypeSort'),
  formattedTaskTypes: function() {
    return this.get('sortedTaskTypes').map(function(taskType) {
      return {
        id: taskType.get('id'),
        text: taskType.get('title')
      };
    });
  }.property('sortedTaskTypes.@each'),
  formattedTaskTypesReady: Ember.computed.notEmpty('formattedTaskTypes'),

  actions: {
    taskTypeSelected(taskType) {
      this.set('taskType', this.get('journalTaskTypes').findBy('id', taskType.id));
    }
  }
});
