ETahi.ApplicationSerializer = DS.ActiveModelSerializer.extend
  # handles outgoing namespaced models
  serialize: (record, options) ->
    json = this._super(record, options)
    if json.qualified_type
      json.type = json.qualified_type
      delete json.qualified_type
    return json

  # handles incoming namespaced models
  # eg. StandardTasks::FigureTask and SupportingInformation::Task
  normalizeType: (hash) ->
    if hash.type
      hash.qualified_type = hash.type
      taskTypeNames = hash.qualified_type.split '::'
      return hash if taskTypeNames.length is 1

      hash.type = Tahi.utils.deNamespaceTaskType(hash.type)

    hash

  # uses correct model name for sideloaded payloads
  extractTypeName: (prop, hash) ->
    if hash.type
      @typeForRoot hash.type
    else
      @typeForRoot prop

  # private function taken directly from ember.js
  coerceId: (id) ->
    (if not id? then null else id + "")

  # allow the sti serializers to override this easily.
  primaryTypeName: (primaryType) ->
    primaryType.typeKey?.camelize()

  # This is overridden from the RESTSerializer because finding a 'task' and getting back a root key of 'author_task' will
  # break the isPrimary check.
  extractSingle: (store, primaryType, payload, recordId) ->
    payload = @normalizePayload(payload)
    primaryTypeName = @primaryTypeName(primaryType)
    primaryRecord = undefined
    for prop of payload
      typeName = @typeForRoot(prop)
      type = store.modelFor(typeName)
      isPrimary = type.typeKey is primaryTypeName
      # legacy support for singular resources
      if isPrimary and Ember.typeOf(payload[prop]) isnt "array"
        hash = payload[prop]
        hash = @normalizeType(hash)
        typeName = @extractTypeName(prop, hash) #custom extract
        primaryType = store.modelFor(typeName)
        primaryRecord = @normalize(primaryType, payload[prop], prop)
        continue

      #jshint loopfunc:true
      for hash in payload[prop]
        # ===========> custom code for namespacing and sti starts here
        hash = @normalizeType(hash)
        typeName = @extractTypeName(prop, hash)
        # <=========== custom code for namespacing and sti ends here
        type = store.modelFor(typeName)
        typeSerializer = store.serializerFor(type)
        hash = typeSerializer.normalize(type, hash, prop)
        isFirstCreatedRecord = isPrimary and not recordId and not primaryRecord
        isUpdatedRecord = isPrimary and @coerceId(hash.id) is recordId

        # find the primary record.
        #
        # It's either:
        # * the record with the same ID as the original request
        # * in the case of a newly created record that didn't have an ID, the first
        #   record in the Array
        if isFirstCreatedRecord or isUpdatedRecord
          primaryRecord = hash
        else
          store.push typeName, hash

    primaryRecord

  extractArray: (store, primaryType, payload) ->
    payload = @normalizePayload(payload)
    primaryTypeName = @primaryTypeName(primaryType)
    primaryArray = undefined
    for prop of payload
      typeKey = prop
      forcedSecondary = false
      if prop.charAt(0) is "_"
        forcedSecondary = true
        typeKey = prop.substr(1)
      typeName = @typeForRoot(typeKey)
      type = store.modelFor(typeName)
      arrayTypeSerializer = store.serializerFor(type) # cache the serializer based on the array's type key
      isPrimary = (not forcedSecondary and (type.typeKey is primaryTypeName))

      #jshint loopfunc:true
      normalizedArray = Ember.ArrayPolyfills.map.call(payload[prop], (hash) ->
        # =======> Each item in the array of tasks could have a different type.
        hash = @normalizeType(hash)
        if hash.type
          itemSerializer = store.serializerFor(hash.type)
        else
          itemSerializer =  arrayTypeSerializer
        itemType = store.modelFor(@extractTypeName(prop, hash))
        itemSerializer.normalize(itemType, hash, prop)
      , this)
      if isPrimary
        primaryArray = normalizedArray
      else
        store.pushMany typeName, normalizedArray
    primaryArray

  pushPayload: (store, payload) ->
    payload = @normalizePayload(payload)
    for prop of payload
      typeName = @typeForRoot(prop)

      #jshint loopfunc:true
      normalizedArray = Ember.ArrayPolyfills.map.call(Ember.makeArray(payload[prop]), (hash) ->
        hash = @normalizeType(hash)
        itemType = store.modelFor(@extractTypeName(prop, hash))
        @normalize itemType, hash, prop
      , this)

      #pushMany will call push and account for the type attributes correctly.
      store.pushMany typeName, normalizedArray
    return
