ETahi.MessageOverlayController = ETahi.TaskController.extend ETahi.ControllerParticipants,
  overlayClass: 'message-overlay'

  setupTooltips: (->
    Ember.run.schedule 'afterRender', ->
      $('.user-thumbnail').tooltip(placement: 'bottom')
  ).observes('model.participants.length')

  actions:
    postComment: (body) ->
      return unless body
      commenter = @getCurrentUser()
      commentFields =
        commenter: commenter
        messageTask: @get('model')
        body: body
        createdAt: new Date()
      newComment = @store.createRecord('comment', commentFields)
      newComment.save()
