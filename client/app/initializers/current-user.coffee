CurrentUser =
  name: 'currentUser'
  after: 'store'
  initialize: (container, application) ->
    if data = window.currentUserData
      store = container.lookup('store:main')
      store.pushPayload(data)
      user = store.getById('user', data.user.id)

      container.register('user:current', user, instantiate: false)
      application.inject('controller', 'currentUser', 'user:current')
      application.inject('route', 'currentUser', 'user:current')

`export default CurrentUser`
