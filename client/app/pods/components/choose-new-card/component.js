import Ember from 'ember';

export default Ember.Component.extend({
  journalTaskTypes: null, // passed-in
  taskTypeSort: ['title:asc'],
  taskTypeList: [],
  sortedTaskTypes: Ember.computed.sort('journalTaskTypes', 'taskTypeSort'),
  authorTasks: Ember.computed.filterBy('sortedTaskTypes', 'role', 'author'),
  staffTasks: Ember.computed.setDiff('sortedTaskTypes', 'authorTasks'),

  actions: {
    updateList(checkbox) {

      if (checkbox.get("checked")) {
        this.get('taskTypeList').addObject(checkbox.get("task"));
      } else {
        this.get('taskTypeList').removeObject(checkbox.get("task"));
      }
    },

    closeAction() {
      this.sendAction('closeAction');
    },

    addTaskType(phase, taskTypeList) {
      this.sendAction('addTaskType', phase, this.get('taskTypeList'));
    }
  }
});
