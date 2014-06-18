ETahi.TaskCommentComponent = Ember.Component.extend
  tagName: 'li'
  classNames: ['message-comment']
  classNameBindings: ['unread']

  unread: Ember.computed.alias 'comment.unread'
  commenter: Ember.computed.alias 'comment.commenter'
  createdAt: Ember.computed.alias 'comment.createdAt'
  body: Ember.computed.alias 'comment.body'
