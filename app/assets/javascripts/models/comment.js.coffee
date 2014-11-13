a = DS.attr
ETahi.Comment = DS.Model.extend
  commenter: DS.belongsTo('user')
  task: DS.belongsTo('task', polymorphic: true)
  body: a('string')
  createdAt: a('date')
  commentLook: DS.belongsTo('commentLook')
  entities: a()

  isUnreadBy: (user) ->
    if commentLook = @get('commentLook')
      Em.isEmpty(commentLook.get('readAt'))

  markReadBy: (user) ->
    cl = @get('commentLook')
    cl.set('readAt', new Date())
    cl.save()
