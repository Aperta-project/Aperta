ETahi.ProfileRoute = Ember.Route.extend
  model: ->
    @getCurrentUser().reload()

  afterModel: (model) ->
    Ember.$.getJSON('/affiliations', (data)->
      model.set('institutions', data.institutions)
    )
