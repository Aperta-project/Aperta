ETahi.NewMessageCardOverlayController = ETahi.NewCardOverlayController.extend
  overlayClass: 'message-overlay'

  disabled: (->
    Ember.isBlank(@get('model.title'))
  ).property('model.title')

  hasComment: (->
    !Ember.isBlank(@get('newComment.body'))
  ).property('newComment.body')

  actions:
    createCard: ->
      initialComment = @get('newComment')
      shouldSaveComment = @get('hasComment')
      @get('model').save().then (task) =>
        if shouldSaveComment
          initialComment.set('task', task)
          initialComment.save()
        else
          initialComment.deleteRecord()
        @send('closeOverlay')
