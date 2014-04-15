ETahi.SerializesHasMany = Ember.Mixin.create
  relationshipMap: ->
    {
      manyToNone: true
      manyToMany: true
      manyToOne: true
    }

  defaultArray: ["-1"]

  overrideEmptyRelation: (arrayLike) ->
    if Em.isEmpty(arrayLike) then @defaultArray else arrayLike

  toSnakeCase: (string)->
    string.replace /([A-Z])/g, ($1)->
      "_" + $1.toLowerCase()

  serializeHasMany: (record, json, relationship) ->
    return unless record.get('relationshipsToSerialize')?.contains(relationship.key)

    key = relationship.key
    idsKey = key.substr(0, key.length-1) + "_ids"
    relationshipType = DS.RelationshipChange.determineRelationshipType(record.constructor, relationship)

    relationshipValue = Em.get(record, key).mapBy("id")
    if @relationshipMap relationshipType
      json[@toSnakeCase(idsKey)] = @overrideEmptyRelation(relationshipValue)
    return
