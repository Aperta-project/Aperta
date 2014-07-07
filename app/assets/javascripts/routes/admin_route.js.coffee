ETahi.AdminRoute = ETahi.AuthorizedRoute.extend
  model: ->
    @store.find('adminJournal')

  actions:
    viewUserDetails: (user) ->
      @controllerFor('adminJournalUser').set('model', user)
      @render 'userDetailOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'adminJournalUser'
