ETahi.NewCardOverlayController = Ember.Controller.extend ETahi.ControllerParticipants,
  actions:
    cancel: ->
      @get('model').deleteRecord()
      @send('closeOverlay')
    createCard: ->
      @get('model').save()
      @send('closeOverlay')
