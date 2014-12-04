ETahi.AdminRoute = ETahi.AuthorizedRoute.extend
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
