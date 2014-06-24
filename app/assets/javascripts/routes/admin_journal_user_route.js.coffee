ETahi.AdminJournalUserRoute = ETahi.AuthorizedRoute.extend
  model: ->
    @store.find('adminJournalUser')
