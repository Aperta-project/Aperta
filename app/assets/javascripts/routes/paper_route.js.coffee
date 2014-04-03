ETahi.PaperRoute = Ember.Route.extend
  model: (params) ->
    @store.find('paper', params.paper_id)

  actions:
    savePaper: ->
      @modelFor('paper').save()

    confirmSubmitPaper: ->
      @modelFor('paper').save()
      @transitionTo('paper.submit')
