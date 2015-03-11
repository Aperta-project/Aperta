`import Ember from 'ember'`

PhaseController = Ember.Controller.extend
  commentLooks: Em.computed -> @store.all('commentLook')
  canRemoveCard: true

  sortedTasks: (->
    @get('model.tasks').sortBy "position"
  ).property()

  actions:
    changePhaseForTask: (taskId, phaseId) ->
      @beginPropertyChanges()
      task = @get('model.tasks').filterBy("id", taskId + "")[0]
      task.set('phase', @store.getById('phase', phaseId))
      task.save()
      @endPropertyChanges()

    updateSortOrder: (updatedOrder) ->
      @beginPropertyChanges()
      @get('model.tasks').forEach (task) ->
        task.set('position', updatedOrder[task.get('id')])
      @endPropertyChanges()
      @get('model.tasks').invoke('save')

`export default PhaseController`
