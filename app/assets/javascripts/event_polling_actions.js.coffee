ETahi.EventPollingActions = {
  polling: (esData)->
    Ember.run =>
      @store.pushPayload('task', esData)
      esData.tasks.forEach (task) =>
        t = @store.findTask(task.id)
        task.phase.get('tasks').addObject(t)
        t.triggerLater('didLoad')
  destroy: (esData)->
    esData.task_ids.forEach (taskId) =>
      task = @store.findTask(taskId)
      task.deleteRecord()
      task.triggerLater('didDelete')
}
