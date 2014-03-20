ETahi.MessageTaskController = ETahi.TaskController.extend
  newCommentBody: ""

  actions:
    clearMessageContent: -> null
    postComment: ->
      userId = Tahi.currentUser.id.toString()
      commenter = @store.all('user').findBy('id', userId)
      commentFields =
        commenter: commenter
        messageTask: @get('model')
        body: @get('newCommentBody')
      newComment = @store.createRecord('comment', commentFields)
