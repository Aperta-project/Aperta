ETahi.CommentBoardComponent = Ember.Component.extend
  comments: []
  commentsDisplayedAsUnread: []
  commentBody: ""
  commentsToShow: 5
  showingAllComments: false

  clearUnread: (->
    @set('commentsDisplayedAsUnread', [])
  ).on('init')

  setupFocus: (->
    @$('.new-comment').on('focus', (e) =>
      @$('.form-group').addClass('editing')
    )
  ).on('didInsertElement')

  setCommentUnreadStates: ( ->
    Ember.run =>
      @get('shownComments').forEach (c) =>
        if c.isUnreadBy(@get('currentUser'))
          @displayCommentAsUnread(c)
          c.markReadBy(@get('currentUser'))
        else
          c.set('unread', false) unless @isCommentDisplayedAsUnread(c)
  ).observes('shownComments.@each').on('init')

  shownComments: (->
    comments = @get('comments').sortBy('createdAt').reverse()
    if @get('showingAllComments') then comments else comments.slice(0, @get("commentsToShow"))
  ).property('comments.@each.createdAt', 'showingAllComments')

  showingAllComments: (->
    @get('comments.length') <= @get('commentsToShow')
  ).property('comments.length')

  omittedCommentsCount: (->
    @get('comments.length') - @get("commentsToShow")
  ).property('comments.length')

  displayCommentAsUnread: (comment) ->
    comment.set('unread', true)
    @get('commentsDisplayedAsUnread').pushObject(comment)

  isCommentDisplayedAsUnread: (comment) ->
    @get('commentsDisplayedAsUnread').contains(comment)

  actions:
    showAllComments: ->
      @set('showingAllComments', true)

    postComment: ->
      @sendAction('postComment', @get("commentBody"))
      @send('clearComment')

    clearComment: ->
      @set('commentBody', "")
      @$('.form-group').removeClass('editing')
