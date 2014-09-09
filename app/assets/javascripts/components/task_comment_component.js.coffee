ETahi.TaskCommentComponent = Ember.Component.extend
  tagName: 'li'
  classNames: ['message-comment']
  classNameBindings: ['unread']

  unread: false
  commenter: Ember.computed.alias 'comment.commenter'
  createdAt: Ember.computed.alias 'comment.createdAt'
  body: Ember.computed.alias 'comment.body'

  setUnreadState: ( ->
    Ember.run =>
      c = @get('comment')
      user = @get('currentUser')
      if c.isUnreadBy(user)
        @set('unread', true)
        c.markReadBy(user)
      else
        @set('unread', false)
  ).on('init')
