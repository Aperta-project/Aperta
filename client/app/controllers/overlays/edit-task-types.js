import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen edit-task-types-overlay',
  taskTypeSort: ['title:asc'],
  sortedTaskTypes: Ember.computed.sort('model.journalTaskTypes', 'taskTypeSort')
});
