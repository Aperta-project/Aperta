ETahi.ProfileRoute = Ember.Route.extend
  beforeModel: (transition) ->
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
