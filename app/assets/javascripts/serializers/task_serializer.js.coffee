ETahi.TaskSerializer = DS.ActiveModelSerializer.extend ETahi.SerializesHasMany,
  normalize: (type, hash) ->
    hash.qualified_type = hash.type
    taskType = hash.type || 'Task'
    hash.type = taskType.replace(/.+::/, '')
    this._super.apply(this, arguments)

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

  # This is overridden because finding a 'task' and getting back a root key of 'author_task' will
  # break the isPrimary check.
  extractSingle: (store, primaryType, payload, recordId, requestType) ->
    payload = @normalizePayload(primaryType, payload)
    primaryTypeName = primaryType.typeKey
    primaryRecord = undefined
    for prop of payload
      typeName = @typeForRoot(prop)
      type = store.modelFor(typeName)
      isPrimary = type.typeKey is primaryTypeName
      # =======Custom check for primary type
      if payload[prop].parent_type == 'task'
        isPrimary = true
        primaryType = type
        primaryTypeName = type.typeKey
      else
        isPrimary = type.typeKey is primaryTypeName
      # =======Custom check for primary type

      # legacy support for singular resources
      if isPrimary and Ember.typeOf(payload[prop]) isnt "array"
        primaryRecord = @normalize(primaryType, payload[prop], prop)
        continue

      #jshint loopfunc:true
      for hash in payload[prop]
        # hash.foobar = 'hello!'
        # custom code starts here
        typeName = if hash.type
          hash.qualified_type = hash.type
          hash.type = hash.type.replace(/.+::/, '')
          @typeForRoot hash.type
        else
          @typeForRoot prop
        # custom code ends here
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
