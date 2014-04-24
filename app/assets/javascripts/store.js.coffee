# http://emberjs.com/guides/models/using-the-store/

ETahi.Store = DS.Store.extend
  # Override the default adapter with the `DS.ActiveModelAdapter` which
  # is built to work nicely with the ActiveModel::Serializers gem.
  adapter: '-active-model'

  push: (type, data, _partial) ->
    oldType = type
    dataType = data.type
    modelType = oldType
    if dataType and (@modelFor(oldType) != @modelFor(dataType)) # is this a subclass?
      modelType = dataType
      if oldRecord = @getById(oldType, data.id)
        @dematerializeRecord(oldRecord)
    @_super @modelFor(modelType), data, _partial

  # find any task in the store even when subclassed
  findTask: (id) ->
    matchingTask = _(@typeMaps).detect (tm) ->
      tm.type.toString().match(/Task$/) and tm.idToRecord[id]
    if matchingTask
      matchingTask.idToRecord[id]
