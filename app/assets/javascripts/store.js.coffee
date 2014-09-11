# http://emberjs.com/guides/models/using-the-store/

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

  # in rare cases the event stream response might outrun the ajax return from the server,
  # leading to duplicate records with the same data.  This method eliminates that exact case.
  didSaveRecord: (record, data) ->
    if data
      existingRecord = @getById(record.constructor.typeKey, data.id) # 'task'
      if record.get('isNew') && existingRecord
        existingRecord.deleteRecord()
    @_super(record, data)
