ETahi.MessageOverlayController = ETahi.TaskController.extend ETahi.ControllerParticipants,
  newCommentBody: ""

  message: true
  overlayClass: 'message-overlay'

  _clearNewMessage: ->
    @set('newCommentBody', "")

  commentSort: ['createdAt:asc']
  sortedComments: Ember.computed.sort('comments', 'commentSort')

  actions:
    clearMessageContent: ->
      @_clearNewMessage()

    postComment: ->
      commenter = @get('currentUser')
      commentFields =
        commenter: commenter
        messageTask: @get('model')
        body: @get('newCommentBody')
        createdAt: new Date()
      newComment = @store.createRecord('comment', commentFields)
      newComment.save()
        .then(@_clearNewMessage.bind(@), newComment.deleteRecord)
        .then(@send('saveNewParticipant', commenter))
