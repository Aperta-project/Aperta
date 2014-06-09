ETahi.EventStreamActions = {
  created: (esData) ->
    Ember.run =>
      if esData.task
        phaseId = esData.task.phase_id
        taskId = esData.task.id
        @store.pushPayload('task', esData)
        task = @store.findTask(taskId)
        phase = @store.getById('phase', phaseId)
        # This is an ember bug.  A task's phase needs to be notified that the other side of
        # the hasMany relationship has changed via set.  Simply loading the updated task into the store
        # won't trigger the relationship update.
        phase.get('tasks').addObject(task)
        task.triggerLater('didLoad')
  updated: (esData)->
    Ember.run =>
      if esData.task
        taskId = esData.task.id
        @store.pushPayload('task', esData)
        task = @store.findTask(taskId)
        task.triggerLater('didLoad')
  destroy: (esData)->
    esData.task_ids.forEach (taskId) =>
      task = @store.findTask(taskId)
      if task
        task.deleteRecord()
        task.triggerLater('didDelete')
}
