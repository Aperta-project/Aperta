ETahi.PaperSubmitRoute = Ember.Route.extend
  actions:
    submitPaper: ->
      @modelFor('paper').set('submitted', true).save().then(
          (succcess) =>
            @transitionTo('index')
          ,
          (errorResponse) =>
            errors = _.values(errorResponse.errors.base).join(' ')
            Tahi.utils.togglePropertyAfterDelay(@controllerFor('paper'), 'errorText', errors, '', 5000)
      )
