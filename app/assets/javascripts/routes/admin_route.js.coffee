ETahi.AdminRoute = Ember.Route.extend
  model: ->
    @store.find('journal')
