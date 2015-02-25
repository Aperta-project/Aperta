`import Ember from 'ember'`

PhaseController = Ember.Controller.extend
  commentLooks: Em.computed -> @store.all('commentLook')
  canRemoveCard: true
  positionSort: ['position:asc']
  sortedTasks: Ember.computed.sort 'model.tasks', 'positionSort'

  actions:
    updatePositions: (currentTask) ->
      relevantTasks = @get('model.tasks').filter (task) ->
        task isnt currentTask and task.get('position') >= currentTask.get('position')

      relevantTasks.invoke('incrementProperty', 'position')

`export default PhaseController`
