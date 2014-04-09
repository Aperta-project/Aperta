ETahi.NewMessageCardOverlayController = ETahi.NewCardOverlayController.extend
  overlayClass: 'message-overlay'

  newComment: Ember.computed.alias('model.comments.firstObject')
  hasComment: (-> 
    !Ember.isBlank(@get('newComment.body'))
  ).property('newComment.body')

  actions:
    createCard: ->
      initialComment = @get('newComment')
      shouldSaveComment = @get('hasComment')
      @get('model').save().then (task) =>
        if shouldSaveComment
          initialComment.save()
        else
          initialComment.deleteRecord()

      @send('closeOverlay')
