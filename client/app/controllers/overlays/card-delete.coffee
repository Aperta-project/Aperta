`import Ember from 'ember'`

CardDeleteOverlayController = Ember.Controller.extend
  overlayClass: 'overlay--fullscreen paper-submit-overlay'

  actions:
    closeAction: ->
      @set('model', null)
      @send('closeOverlay')
    removeTask: ->
      @get('model').destroyRecord().then (task) =>
        @send('closeOverlay')

`export default CardDeleteOverlayController`
