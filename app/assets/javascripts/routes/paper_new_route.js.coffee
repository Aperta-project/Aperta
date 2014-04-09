ETahi.PaperNewRoute = Ember.Route.extend
  model: (params) ->
    @store.find('journal')
