`import AuthorizedRoute from 'tahi/routes/authorized'`

AdminIndexRoute = AuthorizedRoute.extend
  setupController: (controller) ->
    controller.set('promise', @store.find('adminJournal'))

`export default AdminIndexRoute`
