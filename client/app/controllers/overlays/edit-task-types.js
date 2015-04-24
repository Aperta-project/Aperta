import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen edit-task-types-overlay',
  needs: ['admin/journal/index'],
  model: Ember.computed.alias('controllers.admin/journal/index.model'),
  taskTypeSort: ['title:asc'],
  sortedTaskTypes: Ember.computed.sort('model.journalTaskTypes', 'taskTypeSort')
});
