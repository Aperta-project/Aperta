# http://emberjs.com/guides/models/using-the-store/

ETahi.Store = DS.Store.extend
  # Override the default adapter with the `DS.ActiveModelAdapter` which
  # is built to work nicely with the ActiveModel::Serializers gem.
  adapter: '-active-model'

  push: (type, data, _partial) ->
    oldType = type
    dataType = data.type
    modelType = oldType
    if dataType && (@modelFor(oldType) != @modelFor(dataType))
      genericTypeRecord = @recordForId(oldType, data.id)
      modelType = dataType
      @dematerializeRecord(genericTypeRecord)
    @_super @modelFor(modelType), data, _partial
