CurrentUser =
  name: 'currentUser'
  after: 'store'
  initialize: (container, application) ->
    if user = window.currentUser
      container.lookup('store:main').pushPayload(window.currentUser)

      container.register('user:current', (-> window.currentUser), instantiate: false)
      application.inject('controller', 'getCurrentUser', 'user:current')
      application.inject('route', 'getCurrentUser', 'user:current')

`export default CurrentUser`
