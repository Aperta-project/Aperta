ETahi.MessageTaskController = ETahi.TaskController.extend
  newCommentBody: ""

  actions:
    clearMessageContent: -> null
    postComment: ->
      commentFields =
        body: @get('newCommentBody')
      newComment = @store.createRecord('comment', commentFields)
