ETahi.PaperSubmitRoute = Ember.Route.extend
  actions:
    submitPaper: ->
      @modelFor('paper').set('submitted', true).save()
      @transitionTo('index')
