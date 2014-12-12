`import Ember from 'ember'`
`import RESTless from 'tahi/services/rest-less'`

PaperSubmitOverlayController = Ember.ObjectController.extend
  needs: ['application']
  overlayClass: 'overlay--fullscreen paper-submit-overlay'

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property('title', 'shortTitle')

  actions:
    submit: ->
      RESTless.putUpdate(@get('model'), "/submit").then( =>
        @transitionToRoute('application')).catch ({status, model}) =>
          message = switch status
            when 422 then model.get('errors.messages') + " You should probably reload."
            when 403 then "You weren't authorized to do that"
            else "There was a problem saving.  Please reload."

          @get('controllers.application').set('error', message)

`export default PaperSubmitOverlayController`
