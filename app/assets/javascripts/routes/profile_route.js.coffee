ETahi.ProfileRoute = Ember.Route.extend
  model: ->
    @getCurrentUser().reload()

  afterModel: (model) ->
    Ember.$.getJSON('/affiliations', (data)->
      items = []
      data.institutions.forEach (item) ->
        items.push(item)
      model.set('institutions', items)
    )
