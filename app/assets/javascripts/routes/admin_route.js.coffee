ETahi.AdminRoute = ETahi.AuthorizedRoute.extend
  beforeModel: ->
    Ember.$.ajax '/admin/journals/authorization'

  actions:
    viewUserDetails: (user) ->
      @controllerFor('adminJournalUser').set('model', user)
      @render 'userDetailOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'adminJournalUser'

    didTransition: ->
      $('html').attr('screen', 'admin')

    willTransition: ->
      $('html').attr('screen', '')
