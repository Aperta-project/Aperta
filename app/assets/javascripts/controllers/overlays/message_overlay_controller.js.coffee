ETahi.MessageOverlayController = ETahi.TaskController.extend ETahi.ControllerParticipants,
  newCommentBody: ""

  overlayClass: 'message-overlay'

  _clearNewMessage: ->
    @set('newCommentBody', "")

  commentSort: ['createdAt:asc']
  sortedComments: Ember.computed.sort('model.comments', 'commentSort')

  shownComments: (->
    commentsLength =  @get('sortedComments.length')
    comments = @get('sortedComments')
    if @get('showAllComments') then comments else comments.slice(commentsLength - 5)
  ).property('model.comments.length')

  showAllComments: (->
    @get('sortedComments.length') < 6
  ).property('model.comments.length')

  unreadComment: (->
    unreadCommentViews = @get('model.comments').map (comment) (->
      comment.commentViews
    ).filter (commentView) (->
      commentView.readAt == null
    )
    if @get('model.readAt') then true else false
  ).property()

  setupTooltips: (->
    Ember.run.later ->
      $('.user-thumbnail').tooltip(placement: 'bottom')
  ).observes('model.participants.length')

  omittedCommentsCount: (->
    @get('sortedComments.length') - 5
  ).property('model.comments.length')

  actions:
    clearMessageContent: ->
      @_clearNewMessage()

    showAllComments: ->
      @set('shownComments', @get('sortedComments'))
      @set('showAllComments', true)

    postComment: ->
      commenter = @getCurrentUser()
      commentFields =
        commenter: commenter
        messageTask: @get('model')
        body: @get('newCommentBody')
        createdAt: new Date()
      newComment = @store.createRecord('comment', commentFields)
      newComment.save()
        .then(@_clearNewMessage.bind(@), newComment.deleteRecord)
        .then(@send('saveNewParticipant', commenter))
