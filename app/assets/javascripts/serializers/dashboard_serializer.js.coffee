ETahi.DashboardSerializer = ETahi.ApplicationSerializer.extend ETahi.SerializesHasMany,
  normalizeHash:
    tasks: (hash)->
      hash.qualified_type = hash.type
      hash.type = hash.type.replace(/.+::/, '')

