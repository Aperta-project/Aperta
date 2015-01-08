ETahi.SerializesHasMany = Ember.Mixin.create
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
    return unless record.get('relationshipsToSerialize')?.contains(relationship.key)

    key = relationship.key
    idsKey = key.substr(0, key.length-1) + "_ids"
    relationshipType = record.constructor.determineRelationshipType(relationship)
    if @relationshipMap relationshipType
      json[@toSnakeCase(idsKey)] = Em.get(record, key).mapBy("id")
    return
