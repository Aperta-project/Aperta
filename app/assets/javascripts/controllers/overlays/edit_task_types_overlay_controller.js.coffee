ETahi.EditTaskTypesOverlayController = Em.Controller.extend
  overlayClass: 'overlay--fullscreen edit-task-types-overlay'
  needs: ['journalIndex']
  model: Em.computed.alias('controllers.journalIndex.model')
  taskTypeSort: ['title:asc']
  sortedTaskTypes: Ember.computed.sort('model.journalTaskTypes', 'taskTypeSort')
