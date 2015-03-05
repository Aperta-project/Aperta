`import Ember from 'ember'`
`import RESTless from 'tahi/services/rest-less'`

PaperSubmitOverlayController = Ember.Controller.extend
  overlayClass: 'overlay--fullscreen--green paper-submit-overlay'
  paperSubmitted: false

  actions:
    submit: ->
      RESTless.putUpdate(@get('model'), "/submit")
      .then =>
        @set 'paperSubmitted', true
      .catch ({status, model}) =>
        message = switch status
          when 422 then model.get('errors.messages') + " You should probably reload."
          when 403 then "You weren't authorized to do that"
          else "There was a problem saving. Please reload."
        @flash.displayMessage 'error', message

    closeAction: ->
      @transitionToRoute('application')
        .then =>
          @set 'paperSubmitted', false

`export default PaperSubmitOverlayController`
