`import Ember from 'ember'`

CommentBoardComponent = Ember.Component.extend
  classNames: ['comment-board']
  editing: false

  comments: []
  commentBody: ''
  commentsToShow: 5

  commentSort: ['createdAt:desc']
  sortedComments: Ember.computed.sort('comments', 'commentSort')
  firstComments: Ember.computed.filter 'sortedComments', (comment, index) -> index < 5

  setupFocus: (->
    @$('.new-comment-field').on('focus', (e) =>
      @set 'editing', true
    )
  ).on('didInsertElement')

  showingAllComments: (->
    @get('comments.length') <= @get('commentsToShow')
  ).property('comments.length')

  omittedCommentsCount: (->
    @get('comments.length') - @get('commentsToShow')
  ).property('comments.length')

  actions:
    showAllComments: ->
      @set('showingAllComments', true)

    postComment: ->
      @sendAction('postComment', @get('commentBody'))
      @send('clearComment')

    clearComment: ->
      @set('commentBody', '')
      @set('editing', false)

`export default CommentBoardComponent`
