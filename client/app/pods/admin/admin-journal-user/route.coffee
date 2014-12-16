`import Ember from 'ember'`
`import AuthorizedRoute from 'tahi/routes/authorized'`

AdminJournalUserRoute = AuthorizedRoute.extend
  model: ->
    @store.find('adminJournalUser')

`export default AdminJournalUserRoute`
