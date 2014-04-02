ETahi.Comment = DS.Model.extend
  commenter: DS.belongsTo('user')
  messageTask: DS.belongsTo('messageTask')
  body: DS.attr('string')
  createdAt: DS.attr('string')
