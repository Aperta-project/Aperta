`import Ember from 'ember'`

AlertUnsavedChanges = Ember.Mixin.create
  actions:
    willTransition: (transition) ->
      if @controller.get('dirty')
        @set 'attemptingTransition', transition
        transition.abort()
        @render 'overlays/unsaved-data',
          into: 'application'
          outlet: 'overlay'
          controller: 'overlays/unsaved-data'
      else
        # Bubble the `willTransition` action so that
        # parent routes can decide whether or not to abort.
        return true

    discardChanges: ->
      @controller.send 'rollback'
      @get('attemptingTransition').retry()

    cancelTransition: ->
      @send 'closeOverlay'

`export default AlertUnsavedChanges`
