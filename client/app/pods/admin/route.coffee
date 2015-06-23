`import Ember from 'ember'`
`import AuthorizedRoute from 'tahi/routes/authorized'`

AdminRoute = AuthorizedRoute.extend
  beforeModel: ->
    Ember.$.ajax '/api/admin/journals/authorization'

  actions:
    viewUserDetails: (user) ->
      @controllerFor('overlays/userDetail').set('model', user)
      @send('openOverlay', {
        template: 'overlays/userDetail'
        into: 'application'
        outlet: 'overlay'
        controller: 'overlays/userDetail'
      })

    didTransition: ->
      $('html').attr('screen', 'admin')
      return true

    willTransition: ->
      $('html').attr('screen', '')
      return true

`export default AdminRoute`
