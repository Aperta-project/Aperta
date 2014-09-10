a = DS.attr
ETahi.CommentLook = DS.Model.extend
  readAt: a('date')
  comment: DS.belongsTo('comment')
  user: DS.belongsTo('user')
