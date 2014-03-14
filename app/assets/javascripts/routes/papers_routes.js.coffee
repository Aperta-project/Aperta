ETahi.PaperRoute = Ember.Route.extend
  model: (params) ->
    @store.find('paper', params.paper_id)

ETahi.PaperManageRoute = Ember.Route.extend
  model: ->
    @modelFor 'paper'
