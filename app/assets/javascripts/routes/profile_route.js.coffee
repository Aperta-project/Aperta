ETahi.ProfileRoute = Ember.Route.extend
  beforeModel: ->
    Ember.$.getJSON('/users/profile').then (data) =>
      @store.pushPayload 'currentUser', currentUser: data.user

  model: -> @store.all('currentUser').get 'firstObject'
