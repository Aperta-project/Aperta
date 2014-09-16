ETahi.ChooseNewCardTypeOverlayController = Em.Controller.extend
  taskTypeSort: ['title:asc']
  sortedTaskTypes: Ember.computed.sort('journalTaskTypes', 'taskTypeSort')
