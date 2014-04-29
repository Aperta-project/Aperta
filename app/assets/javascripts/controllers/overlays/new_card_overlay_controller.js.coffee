ETahi.NewCardOverlayController = Ember.Controller.extend ETahi.ControllerParticipants,
  overlayClass: 'new-adhoc-overlay'

  actions:
    cancel: ->
      @get('model').deleteRecord()
      @send('closeOverlay')
    createCard: ->
      @get('model').save().then (model) ->
        model.get('phase.tasks').pushObject(model)
      @send('closeOverlay')
