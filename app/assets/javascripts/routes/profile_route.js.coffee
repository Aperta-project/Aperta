ETahi.ProfileRoute = Ember.Route.extend
  model: ->
    # TODO: alternative implementation, may be needed for the Edit action
    Ember.$.getJSON('/users/profile').then((data) =>
      @store.pushPayload 'user', data
      @controllerFor('application').set('currentUserId', data.user.id)
      @store.find('user', data.user.id)
    , ->
      transition.abort()
      @transitionTo('index')
    )

  afterModel: (model) ->
    Ember.$.getJSON('/affiliations', (data)->
      items = []
      data.institutions.forEach (item) ->
        items.push(item)
      model.set('institutions', items)
    )
