ETahi.PaperSubmitRoute = Ember.Route.extend
  model: ->
    @modelFor('paper')

  actions:
    submitPaper: ->
      @modelFor('paper').set('submitted', true).save()
      @transitionTo('index')
