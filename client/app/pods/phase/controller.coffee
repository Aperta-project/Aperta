`import Ember from 'ember'`

PhaseController = Ember.Controller.extend
  needs: ['paper/manage']
  paperManageController: Em.computed.alias 'controllers.paper/manage'

  commentLooks: Em.computed -> @store.all('commentLook')
  canRemoveCard: true

  sortedTasks: (->
    @get('model.tasks').sortBy "position"
  ).property('model.tasks.[]')

  noCards: Ember.computed.empty('sortedTasks')

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

  getTaskByID: (taskId) ->
    @get('model.tasks').find (t) -> t.get("id") == taskId.toString()


  actions:
    changePhaseForTask: (taskId, targetPhaseId) ->
      @beginPropertyChanges()
      @store.getById('phase', targetPhaseId)
            .get('tasks').addObject(@getTaskByID(taskId))
      @endPropertyChanges()

    updateSortOrder: (updatedOrder) ->
      @beginPropertyChanges()
      @get('model.tasks').forEach (task) ->
        task.set('position', updatedOrder[task.get('id')])
      @endPropertyChanges()
      @get('model.tasks').invoke('save')

`export default PhaseController`
