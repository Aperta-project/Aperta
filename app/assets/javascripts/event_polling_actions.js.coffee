ETahi.EventPollingActions = {
  created: (esData) ->
    Ember.run =>
      @store.pushPayload('task', esData)
    esData.tasks.forEach (task) ->
      # ETahi.EventStreamActions.created(task)
      # maybe need to add context
      phaseId = task.phase_id
      taskId = task.id
      task = @store.findTask(taskId)
      phase = @store.getById('phase', phaseId)
      phase.get('tasks').addObject(task)
      task.triggerLater('didLoad')
  updated: (esData)->
    Ember.run =>
      @store.pushPayload('task', esData)
  destroy: (esData)->
    esData.task_ids.forEach (taskId) =>
      task = @store.findTask(taskId)
      task.deleteRecord()
      task.triggerLater('didDelete')
}
