ETahi.MessageOverlayController = ETahi.TaskController.extend ETahi.ControllerParticipants,
  overlayClass: 'message-overlay'

  setupTooltips: (->
    Ember.run.schedule 'afterRender', ->
      $('.user-thumbnail').tooltip(placement: 'bottom')
  ).observes('model.participants.length')
