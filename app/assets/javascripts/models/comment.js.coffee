ETahi.Comment = DS.Model.extend
  commenter: DS.belongsTo('user')
  body: DS.attr('string')
  messageTask: DS.belongsTo('messageTask')
  createdAt: DS.attr('string')
