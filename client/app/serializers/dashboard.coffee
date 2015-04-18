`import ApplicationSerializer from 'tahi/serializers/application'`

DashboardSerializer = ApplicationSerializer.extend
  normalizeHash:
    tasks: (hash)->
      hash = @normalizeType(hash)

`export default DashboardSerializer`
