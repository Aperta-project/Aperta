ETahi.MessageOverlayController = ETahi.TaskController.extend
  overlayClass: 'message-overlay'

  setupTooltips: (->
    Ember.run.schedule 'afterRender', ->
      $('.user-thumbnail').tooltip(placement: 'bottom')
  ).observes('model.participants.length')
