ETahi.ProfileRoute = Ember.Route.extend
  beforeModel: (transition) ->
    # TODO: alternative implementation, may be needed for the Edit action
    Ember.$.getJSON('/users/profile').then((data) =>
      @store.pushPayload 'user', data
      @controllerFor('application').set('currentUserId', data.user.id)
    , ->
      transition.abort()
      @transitionTo('index')
    )

  model: ->
    id = @controllerFor('application').get('currentUserId')
    @store.find('user', id)
