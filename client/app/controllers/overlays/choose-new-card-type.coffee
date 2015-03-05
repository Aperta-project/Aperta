`import Ember from 'ember'`

ChooseNewCardTypeOverlayController = Ember.Controller.extend
  taskTypeSort: ['title:asc']
  sortedTaskTypes: Ember.computed.sort('journalTaskTypes', 'taskTypeSort')
  overlayClass: 'overlay--fullscreen choose-new-card-type-overlay' 

`export default ChooseNewCardTypeOverlayController`
