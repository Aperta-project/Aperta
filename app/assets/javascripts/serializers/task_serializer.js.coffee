ETahi.normalizeTask = (hash)->
  hash.qualified_type = hash.type
  hash.type = hash.type.replace(/.+::/, '')

ETahi.TaskSerializer = DS.ActiveModelSerializer.extend ETahi.SerializesHasMany,
  normalizeHash:
    task: ETahi.normalizeTask
    tasks: ETahi.normalizeTask

  serializeIntoHash: (data, type, record, options) ->
      root = 'task'
      data[root] = this.serialize(record, options)

  serialize: (record, options) ->
    json = this._super(record, options)
    if json.qualified_type
      json.type = json.qualified_type
      delete json.qualified_type
    return json

  coerceId: (id) ->
    (if not id? then null else id + "")

  normalizeType: (hash) ->
    if hash.type
      hash.qualified_type = hash.type
      hash.type = hash.type.replace(/.+::/, '')
    hash

  extractTypeName: (prop, hash) ->
    if hash.type
      @typeForRoot hash.type
    else
      @typeForRoot prop

  # This is overridden because finding a 'task' and getting back a root key of 'author_task' will
  # break the isPrimary check.
  extractSingle: (store, primaryType, payload, recordId, requestType) ->
    payload = @normalizePayload(primaryType, payload)
    primaryTypeName = 'task'
    primaryRecord = undefined
    for prop of payload
      typeName = @typeForRoot(prop)
      type = store.modelFor(typeName)
      isPrimary = type.typeKey is primaryTypeName
      # legacy support for singular resources
      if isPrimary and Ember.typeOf(payload[prop]) isnt "array"
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
    payload = @normalizePayload(primaryType, payload)
    # primaryTypeName = primaryType.typeKey
    primaryTypeName = 'task' # we'll always look for tasks at the root.
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

ETahi.PaperReviewerTaskSerializer = ETahi.TaskSerializer.extend()
ETahi.PaperEditorTaskSerializer = ETahi.TaskSerializer.extend()
ETahi.PaperAdminTaskSerializer = ETahi.TaskSerializer.extend()
ETahi.AuthorsTaskSerializer = ETahi.TaskSerializer.extend()
ETahi.DeclarationTaskSerializer= ETahi.TaskSerializer.extend()
ETahi.FigureTaskSerializer= ETahi.TaskSerializer.extend()
ETahi.MessageTaskSerializer= ETahi.TaskSerializer.extend()
ETahi.TechCheckTaskSerializer= ETahi.TaskSerializer.extend()
ETahi.RegisterDecisionTaskSerializer= ETahi.TaskSerializer.extend()
ETahi.ReviewerReportTaskSerializer= ETahi.TaskSerializer.extend()
ETahi.UploadManuscriptTaskSerializer= ETahi.TaskSerializer.extend()
