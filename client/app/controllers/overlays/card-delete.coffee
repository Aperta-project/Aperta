`import Ember from 'ember'`

CardDeleteOverlayController = Ember.ObjectController.extend
  overlayClass: 'overlay--fullscreen paper-submit-overlay'

  task: null

  actions:
    submit: ->
      @send('removeTask')
      @send('closeOverlay')
    closeAction: ->
      @set('task', null)
      @send('closeOverlay')
    removeTask: (task) ->
      @get('task').destroyRecord()

`export default CardDeleteOverlayController`
