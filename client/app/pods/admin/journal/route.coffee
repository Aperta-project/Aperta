`import Ember from 'ember'`

JournalRoute = Ember.Route.extend
  model: (params) -> @store.find('adminJournal', params.journal_id)

`export default JournalRoute`
