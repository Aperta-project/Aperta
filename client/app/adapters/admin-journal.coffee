`import DS from 'ember-data'`

AdminJournalAdapter = DS.ActiveModelAdapter.extend
  pathForType: (type) ->
    'admin/journals'

`export default AdminJournalAdapter`
