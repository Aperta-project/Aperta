ETahi.PaperSubmitOverlayController = Ember.ObjectController.extend
  overlayClass: 'overlay--fullscreen paper-submit-overlay'

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property('title', 'shortTitle')

  actions:
    submit: ->
      @get('model').setProperties(submitted: true, editable: false).save().then(
          (success) =>
            @transitionToRoute('application')
          ,
          (errorResponse) =>
            errors = _.values(errorResponse.errors.base).join(' ')
            Tahi.utils.togglePropertyAfterDelay(@, 'errorText', errors, '', 5000)
      )
