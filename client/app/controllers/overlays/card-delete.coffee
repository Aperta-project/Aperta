`import Ember from 'ember'`

CardDeleteOverlayController = Ember.Controller.extend
  overlayClass: 'overlay--fullscreen paper-submit-overlay'

  actions:
    closeAction: ->
      @set('model', null)
      @send('closeOverlay')
    removeTask: ->
      @get('model').destroyRecord().then (task) =>
        # EMBERCLI TODO - Polymorphic destroy appears to be broken
        task.get('phase.tasks').removeObject(task) if task.get('phase')
        @send('closeOverlay')

`export default CardDeleteOverlayController`
