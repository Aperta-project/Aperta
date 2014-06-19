ETahi.AdminJournalUserSerializer = ETahi.ApplicationSerializer.extend
  # Overriding extractArray to make sure findAll works.
  extractArray: (store, primaryType, payload) ->
    payload = @normalizePayload(primaryType, payload)
    # primaryTypeName = primaryType.typeKey
    # primaryTypeName = @primaryTypeName(primaryType)
    primaryTypeName = "adminJournalUser"
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
