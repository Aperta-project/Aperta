ETahi.MessageOverlayController = ETahi.TaskController.extend ETahi.ControllerParticipants,
  newCommentBody: ""

  message: true
  overlayClass: 'message-overlay'

  _clearNewMessage: ->
    @set('newCommentBody', "")

  commentSort: ['createdAt:desc']
  sortedComments: Ember.computed.sort('model.comments', 'commentSort')

  shownComments: (->
    @get('sortedComments').slice(0,5).reverseObjects()
  ).property('model.comments.@each')

  showAllComments: (->
    @get('sortedComments.length') > 5
  ).property('model.comments.length')

  omittedCommentsCount: (->
    @get('sortedComments.length') - 5
  ).property('model.comments.length')

  actions:
    clearMessageContent: ->
      @_clearNewMessage()

    showAllComments: ->
      @set('shownComments', @get('sortedComments').reverseObjects())
      @set('showAllComments', false)

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
