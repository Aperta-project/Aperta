ETahi.CommentView = Ember.View.extend
  templateName: 'overlays/comment'
  tagName: 'li'
  classNames: ['message-comment']
  classNameBindings: ['controller.unread:unread', 'controller.isDisplayed:shown:hidden']
