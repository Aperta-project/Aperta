ETahi.CommentView = Ember.View.extend
  templateName: 'overlays/comment'
  tagName: 'li'
  classNames: ['message-comment']
  classNameBindings: ['controller.unread:unread']

  setCommentLook: (->
    @get('controller').send 'updateReadAt' if @get('controller.unread')
  ).on('didInsertElement')
