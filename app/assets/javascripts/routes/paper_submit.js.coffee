ETahi.PaperSubmitRoute = Ember.Route.extend
  beforeModel: (transition) ->
    if @modelFor('paper').get('submitted')
      @transitionTo('application')

  actions:
    submitPaper: ->
      @modelFor('paper').set('submitted', true).save().then(
          (succcess) =>
            @transitionTo('application')
          ,
          (errorResponse) =>
            errors = _.values(errorResponse.errors.base).join(' ')
            Tahi.utils.togglePropertyAfterDelay(@controllerFor('paper'), 'errorText', errors, '', 5000)
      )
