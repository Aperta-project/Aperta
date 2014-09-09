a = DS.attr
ETahi.Comment = DS.Model.extend
  commenter: DS.belongsTo('user')
  task: DS.belongsTo('task', polymorphic: true)
  body: a('string')
  createdAt: a('date')
  commentLooks: DS.hasMany('commentLook')

  isUnreadBy: (user) ->
    if commentLook = @commentLookFor(user)
      Em.isEmpty(commentLook.get('readAt'))

  markReadBy: (user) ->
    cl = @commentLookFor(user)
    cl.set('readAt', new Date())
    cl.save()

  commentLookFor: (user) ->
    @get('commentLooks').findProperty('user', user)
