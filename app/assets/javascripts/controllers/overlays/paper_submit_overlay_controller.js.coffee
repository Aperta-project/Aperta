ETahi.PaperSubmitOverlayController = Ember.ObjectController.extend
  overlayClass: 'overlay--fullscreen paper-submit-overlay'

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property('title', 'shortTitle')

  actions:
    submit: ->
      @get('model').set('submitted', true).save().then(
          (succcess) =>
            @transitionToRoute('application')
          ,
          (errorResponse) =>
            errors = _.values(errorResponse.errors.base).join(' ')
            Tahi.utils.togglePropertyAfterDelay(@, 'errorText', errors, '', 5000)
      )
