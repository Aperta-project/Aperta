`import DS from 'ember-data'`

a = DS.attr

CommentLook = DS.Model.extend

  comment: DS.belongsTo('comment')
  user: DS.belongsTo('user')

  readAt: a('date')
  taskId: a('string')
  paperId: a('string')


`export default CommentLook`
