`import Ember from 'ember'`
`import AuthorizedRoute from 'tahi/routes/authorized'`

AdminRoute = AuthorizedRoute.extend
  beforeModel: ->
    Ember.$.ajax '/admin/journals/authorization'

  actions:
    viewUserDetails: (user) ->
      @controllerFor('userDetailOverlay').set('model', user)
      @render 'userDetailOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'userDetailOverlay'

    didTransition: ->
      $('html').attr('screen', 'admin')

    willTransition: ->
      $('html').attr('screen', '')
      return true

`export default AdminRoute`
