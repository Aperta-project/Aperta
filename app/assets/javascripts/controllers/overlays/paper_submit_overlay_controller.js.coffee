ETahi.PaperSubmitOverlayController = Ember.ObjectController.extend
  overlayClass: 'overlay--fullscreen paper-submit-overlay'

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property('title', 'shortTitle')

  actions:
    submit: ->
      ETahi.RESTless.putUpdate(@get('model'), "/submit").then( =>
          @transitionToRoute('application')
        ,
        (errorResponse) =>
          errors = _.values(errorResponse.errors.base).join(' ')
          Tahi.utils.togglePropertyAfterDelay(@, 'errorText', errors, '', 5000)
    )
