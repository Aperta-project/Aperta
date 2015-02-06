`import DS from 'ember-data'`

AdminJournalUserAdapter = DS.ActiveModelAdapter.extend
  pathForType: (type) ->
    'admin/journal_users'

`export default AdminJournalUserAdapter`
