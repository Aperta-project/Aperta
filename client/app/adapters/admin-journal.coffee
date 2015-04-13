`import ApplicationAdapter from 'tahi/adapters/application'`

AdminJournalAdapter = ApplicationAdapter.extend
  pathForType: (type) ->
    'admin/journals'

`export default AdminJournalAdapter`
