CurrentUser =
  name: 'currentUser'
  after: 'store'
  initialize: (container, application) ->
    if userInfo = window.currentUser
      store = container.lookup('store:main')
      store.pushPayload(userInfo)
      user = store.getById('user', userInfo.user.id)

      container.register('user:current', user, instantiate: false)
      application.inject('controller', 'currentUser', 'user:current')
      application.inject('route', 'currentUser', 'user:current')

`export default CurrentUser`
