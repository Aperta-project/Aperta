ETahi.JournalTaskTypesIndexController = Ember.ArrayController.extend
  taskTypeSort: ['title:asc']
  sortedTaskTypes: Ember.computed.sort('model', 'taskTypeSort')
