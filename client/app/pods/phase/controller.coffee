`import Ember from 'ember'`

PhaseController = Ember.Controller.extend
  commentLooks: Em.computed -> @store.all('commentLook')
  canRemoveCard: true
  positionSort: ['position:asc']
  sortedTasks: Ember.computed.sort 'model.tasks', 'positionSort'

`export default PhaseController`
