ETahi.NewCardOverlayController = Ember.Controller.extend ETahi.ControllerParticipants,
  overlayClass: 'new-adhoc-overlay'

  actions:
    cancel: ->
      @get('model').deleteRecord()
      @send('closeOverlay')
    createCard: ->
      @get('model').save()
      @send('closeOverlay')
