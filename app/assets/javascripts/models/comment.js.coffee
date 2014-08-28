a = DS.attr
ETahi.Comment = DS.Model.extend
  commenter: DS.belongsTo('user')
  task: DS.belongsTo('task')
  body: a('string')
  createdAt: a('date')
  commentLook: DS.belongsTo('commentLook')

  isUnread: ->
    if commentLook = @get('commentLook')
      Em.isEmpty(commentLook.get('readAt'))

  isRead: ->
    !@isUnread()

  markRead: ->
    @get('commentLook').set('readAt', new Date())
    @get('commentLook').save()

