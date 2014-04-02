ETahi.ApplicationSerializer = DS.ActiveModelSerializer.extend
  #when tasks are sideloaded cache their ids and types for polymorphism
  normalizePayload: (primaryType, payload) ->
    tasks = payload.tasks
    if tasks
      taskHash = _.reduce(tasks, (memo, task) ->
        memo[task.id] = {id: task.id, type: task.type}
        memo
      , {})
      ETahi.taskTypes = taskHash
    @_super(primaryType, payload)

