`import DS from 'ember-data'`

a = DS.attr

Comment = DS.Model.extend

  commenter: DS.belongsTo('user')
  task: DS.belongsTo('task', polymorphic: true)
  commentLook: DS.belongsTo('commentLook', inverse: 'comment')

  body: a('string')
  createdAt: a('date')
  entities: a()

`export default Comment`
