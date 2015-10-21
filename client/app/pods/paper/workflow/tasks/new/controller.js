import Ember from 'ember';

export default Ember.Controller.extend({
  taskType: null,
  taskTypeSort: ['title:asc'],
  sortedTaskTypes: Ember.computed.sort('journalTaskTypes', 'taskTypeSort'),
  formattedTaskTypesReady: Ember.computed.notEmpty('formattedTaskTypes'),
  formattedTaskTypes: Ember.computed('sortedTaskTypes.[]', function() {
    return this.get('sortedTaskTypes').map(function(taskType) {
      return {
        id: taskType.get('id'),
        text: taskType.get('title')
      };
    });
  }),

  actions: {
    taskTypeSelected(taskType) {
      this.set('taskType', this.get('journalTaskTypes').findBy('id', taskType.id));
    }
  }
});
