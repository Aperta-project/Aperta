ETahi.NewCardOverlayController = Ember.Controller.extend ETahi.ControllerParticipants,
  overlayClass: (->
    if @get('model.type') == 'MessageTask' then 'message-overlay' else 'new-adhoc-overlay'
  ).property('model')

  actions:
    cancel: ->
      @get('model').deleteRecord()
      @send('closeOverlay')
    createCard: ->
      @get('model').save()
      @send('closeOverlay')
