`import Ember from 'ember'`

PhaseController = Ember.Controller.extend
  commentLooks: Em.computed -> @store.all('commentLook')
  canRemoveCard: true

  sortedTasks: (->
    @get('model.tasks').sortBy "position"
  ).property "model.tasks.@each.position"

  actions:
    updatePositions: (currentTask) ->
      relevantTasks = @get('model.tasks').filter (task) ->
        task isnt currentTask

      relevantTasks.invoke('reload')

`export default PhaseController`
