`import Ember from 'ember'`

ChooseNewCardTypeOverlayController = Ember.Controller.extend
  taskTypeSort: ['title:asc']
  sortedTaskTypes: Ember.computed.sort('journalTaskTypes', 'taskTypeSort')

`export default ChooseNewCardTypeOverlayController`
