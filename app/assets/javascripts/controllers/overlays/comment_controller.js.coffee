ETahi.CommentController = Ember.ObjectController.extend
  unread: (->
    @get('model.commentLook') isnt null
  ).property()

  actions:
    updateReadAt: ->
      commentLook = @get 'model.commentLook'
      currentDate = new Date()
      commentLook.set 'readAt', currentDate
      commentLook.save()
