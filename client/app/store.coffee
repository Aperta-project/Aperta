`import DS from 'ember-data'`

ApplicationStore = DS.Store.extend

  push: (type, data, _partial) ->
    oldType = type
    dataType = data.type
    modelType = oldType
    if dataType and (@modelFor(oldType) != @modelFor(dataType)) # is this a subclass?
      modelType = dataType
      if oldRecord = @getById(oldType, data.id)
        @dematerializeRecord(oldRecord)
    @_super @modelFor(modelType), data, _partial

  # find any task by id regardless of subclass
  findTask: (id) ->
    matchingTask = @allTaskClasses().find (tm) -> tm.idToRecord[id]
    if matchingTask
      matchingTask.idToRecord[id]

  # all task classes including subclasses
  allTaskClasses: ->
    Ember.keys(@typeMaps).reduce((memo, key) =>
      typeMap = @typeMaps[key]
      if typeMap.type.toString().match(/:.*task:/)
        memo.addObject(typeMap)
      memo
    , [])

`export default ApplicationStore`
