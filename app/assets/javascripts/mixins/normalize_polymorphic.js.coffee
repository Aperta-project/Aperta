ETahi.NormalizePolymorphic = Ember.Mixin.create
  normalize: (type, hash, prop) ->
    if ETahi.taskTypes
      taskObjs = []
      for taskId in hash.task_ids
        taskObjs.push ETahi.taskTypes[taskId]
      hash.tasks = taskObjs
      delete hash.task_ids
    @_super(type, hash, prop)
