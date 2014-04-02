ETahi.FlowSerializer = DS.ActiveModelSerializer.extend
  normalizePayload: (primaryType, payload) ->
    tasks = payload.tasks
    taskHash = _.reduce(tasks, (memo, task) ->
      memo[task.id] = task
      memo
    , {})
    for flow in payload.flows
      taskObjs = []
      for taskId in flow.task_ids
        taskObjs.push {id: taskId, type: taskHash[taskId].type}
      flow.tasks = taskObjs
      delete flow.task_ids

    for phase in payload.phases
      taskObjs = []
      for taskId in phase.task_ids
        taskObjs.push {id: taskId, type: taskHash[taskId].type}
      phase.tasks = taskObjs
      delete phase.task_ids

    payload

  relationshipMap: ->
    {
      manyToNone: true
      manyToMany: true
      manyToOne: true
    }

  toSnakeCase: (string)->
    string.replace /([A-Z])/g, ($1)->
      "_" + $1.toLowerCase()

  serializeHasMany: (record, json, relationship) ->
    key = relationship.key
    idsKey = key.substr(0, key.length-1) + "_ids"
    relationshipType = DS.RelationshipChange.determineRelationshipType(record.constructor, relationship)
    if @relationshipMap relationshipType
      json[@toSnakeCase(idsKey)] = Em.get(record, key).mapBy("id")
    return
