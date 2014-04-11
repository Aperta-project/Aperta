ETahi.PaperEditRoute = Ember.Route.extend
  afterModel: (model) ->
    @transitionTo('paper.index', model) if model.get('submitted')

  actions:
    viewCard: (task) ->
      paper = @modelFor('paper')
      redirectParams = ['paper.edit', @modelFor('paper')]
      @controllerFor('application').set('overlayRedirect', redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/edit')
      @transitionTo('paper.task', paper, task.id)

    confirmSubmitPaper: ->
      @modelFor('paperEdit').save()
      @transitionTo('paper.submit')

    savePaper: ->
      @modelFor('paperEdit').save()
