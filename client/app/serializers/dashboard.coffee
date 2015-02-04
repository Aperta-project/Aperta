`import ApplicationSerializer from 'tahi/serializers/application'`
`import SerializesHasMany from 'tahi/mixins/serializers/serializes-has-many'`

DashboardSerializer = ApplicationSerializer.extend SerializesHasMany,
  normalizeHash:
    tasks: (hash)->
      hash.qualified_type = hash.type
      hash.type = hash.type.replace(/.+::/, '')

`export default DashboardSerializer`
