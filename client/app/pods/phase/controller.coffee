`import Ember from 'ember'`

PhaseController = Ember.Controller.extend
  commentLooks: Em.computed -> @store.all('commentLook')
  canRemoveCard: true
  sortedTasks: Ember.computed.sort 'model.tasks', ['position:asc']

`export default PhaseController`
