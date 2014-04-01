ETahi.PaperNewRoute = Ember.Route.extend
  model: (params) ->
    # Hit /journals
    {shortTitle: null}

  afterModel: (data) ->


  actions:
    createNewPaper: ->
      paperData = @.modelFor('paper_new')
      newPaper = @store.createRecord('paper', paperData)
