ETahi.ProfileRoute = Ember.Route.extend
  beforeModel: (transition) ->
    # TODO: alternative implementation, may be needed for the Edit action
    # Ember.$.getJSON('/users/profile').then (data) =>
    #   @store.pushPayload 'currentUser', currentUser: data.user
    if ETahi.currentUser
      @store.pushPayload 'currentUser', currentUser: ETahi.currentUser.user
    else
      transition.abort()
      @transitionTo('index')

  model: -> @store.all('currentUser').get 'firstObject'
