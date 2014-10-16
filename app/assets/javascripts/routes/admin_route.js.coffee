ETahi.AdminRoute = ETahi.AuthorizedRoute.extend
  setupController: (controller) ->
    controller.set 'isLoading', true

    @store.find('adminJournal').then (data) ->
      controller.set 'isLoading', false
      controller.set 'model', data

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
