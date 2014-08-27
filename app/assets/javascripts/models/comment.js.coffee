a = DS.attr
ETahi.Comment = DS.Model.extend
  commenter: DS.belongsTo('user')
  task: DS.belongsTo('task')
  body: a('string')
  createdAt: a('date')
  commentLook: DS.belongsTo('commentLook')
