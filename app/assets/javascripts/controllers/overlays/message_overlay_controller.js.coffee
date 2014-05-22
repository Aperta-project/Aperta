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
      body = @get('newCommentBody')
      return unless body
      commenter = @getCurrentUser()
      commentFields =
        commenter: commenter
        messageTask: @get('model')
        body: body
        createdAt: new Date()
        hasBeenRead: true
      newComment = @store.createRecord('comment', commentFields)
      newComment.save()
        .then(@_clearNewMessage.bind(@), newComment.deleteRecord)
        .then(@send('saveNewParticipant', commenter))
