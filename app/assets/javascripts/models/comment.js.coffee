a = DS.attr
ETahi.Comment = DS.Model.extend
  commenter: DS.belongsTo('user')
  task: DS.belongsTo('task', polymorphic: true)
  body: a('string')
  createdAt: a('date')
  commentLook: DS.belongsTo('commentLook')

  isUnread: (->
    if commentLook = @get('commentLook')
      Em.isEmpty(commentLook.get('readAt'))
  ).property('commentLook')

  isRead: Em.computed.not('isUnread')

  markRead: ->
    cl = @get('commentLook')
    cl.set('readAt', new Date())
    cl.save()
