`import ApplicationSerializer from 'tahi/serializers/application'`

DashboardSerializer = ApplicationSerializer.extend
  normalizeHash:
    tasks: (hash)->
      hash.qualified_type = hash.type
      hash.type = hash.type.replace(/.+::/, '')

`export default DashboardSerializer`
