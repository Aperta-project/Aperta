ETahi.ApplicationStore = DS.Store.extend
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

  # find any task by id regardless of subclass
  findTask: (id) ->
    matchingTask = _(@get('allTaskClasses')).detect (tm) -> tm.idToRecord[id]
    if matchingTask
      matchingTask.idToRecord[id]

  # all task classes including subclasses
  allTaskClasses:(->
    _(@typeMaps).filter (tm) ->
      tm.type.toString().match(/Task$/)
  ).property().volatile()

  # resume the event stream after saving
  didSaveRecord: (record, data) ->
    @_super(record, data)
    es = @container.lookup('eventstream:main')
    es.play()

DS.Model.reopen
  # before performing a save pause the event stream
  adapterWillCommit: ->
    es = @container.lookup('eventstream:main')
    es.pause()
    @send('willCommit')
