ETahi.JournalRoute = Ember.Route.extend
  model: (params) ->
    @store.find('journal', params.journal_id)
