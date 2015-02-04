`import DS from 'ember-data'`

a = DS.attr

Comment = DS.Model.extend

  commenter: DS.belongsTo('user')
  task: DS.belongsTo('task', polymorphic: true)
  commentLook: DS.belongsTo('comment-look')

  body: a('string')
  createdAt: a('date')
  entities: a()

  isUnreadBy: (user) ->
    if commentLook = @get('commentLook')
      Em.isEmpty(commentLook.get('readAt'))

  markReadBy: (user) ->
    cl = @get('commentLook')
    cl.set('readAt', new Date())
    cl.save()

`export default Comment`
