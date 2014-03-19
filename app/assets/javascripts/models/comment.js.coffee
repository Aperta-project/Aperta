a = DS.attr
ETahi.Comment = DS.Model.extend
  body: a('string')
  task: DS.belongsTo('task')
