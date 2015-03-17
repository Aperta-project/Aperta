`import Ember from 'ember'`

PhaseController = Ember.Controller.extend
  needs: ['paper/manage']
  paperManageController: Em.computed.alias 'controllers.paper/manage'

  commentLooks: Em.computed -> @store.all('commentLook')
  canRemoveCard: true

  sortedTasks: (->
    @get('model.tasks').sortBy "position"
  ).property()

  tasksToBeDeleted: (->
    currentTaskIds = @get('model.tasks').map (task) -> task.get('id')
    sortedTaskIds  = @get('sortedTasks').map (task) -> task.get('id')

    newTaskAddedId = _.difference(currentTaskIds,
                                  sortedTaskIds,
                                  @get('paperManageController.allTaskIdsSnapshot'))[0]

    allTaskIds = @get('paperManageController').allTaskIds()

    if newTaskAddedId
      @set 'sortedTasks', @get('model.tasks').sortBy('position')
      @set 'paperManageController.allTaskIdsSnapshot', allTaskIds
    else
      @get('paperManageController.allTaskIdsSnapshot').forEach (taskId) ->
        wasDeleted = allTaskIds.indexOf(taskId) == -1
        if wasDeleted
          $("[data-id=#{taskId}]").parent().remove()

  ).observes('model.tasks').on('init')

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
