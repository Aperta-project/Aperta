import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen choose-new-card-type-overlay',
  taskTypeSort: ['title:asc'],
  taskList: [],
  sortedTaskTypes: Ember.computed.sort('journalTaskTypes', 'taskTypeSort'),
  authorTasks: Ember.computed.filterBy('sortedTaskTypes', 'role', 'author'),
  staffTasks: Ember.computed.setDiff('sortedTaskTypes', 'authorTasks'),

  actions: {

    updateList(checkbox) {

      if (checkbox.get("checked")) {
        this.get('taskList').addObject(checkbox.get("task"));
      } else {
        this.get('taskList').removeObject(checkbox.get("task"));
      }
    }
  }
});
