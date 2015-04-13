`import ApplicationAdapter from 'tahi/adapters/application'`

AdminJournalUserAdapter = ApplicationAdapter.extend
  pathForType: (type) ->
    'admin/journal_users'

`export default AdminJournalUserAdapter`
