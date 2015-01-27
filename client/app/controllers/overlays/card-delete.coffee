`import Ember from 'ember'`

CardDeleteOverlayController = Ember.ObjectController.extend
  overlayClass: 'overlay--fullscreen paper-submit-overlay'

  actions:
    closeAction: ->
      @set('task', null)
      @send('closeOverlay')
    removeTask: ->
      @get('model').destroyRecord().then (task) =>
        # EMBERCLI TODO - Polymorphic destroy appears to be broken
        task.get('phase.tasks').removeObject(task)
        @send('closeOverlay')

`export default CardDeleteOverlayController`
