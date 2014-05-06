ETahi.ProfileRoute = Ember.Route.extend
  model: ->
    @getCurrentUser().reload()
