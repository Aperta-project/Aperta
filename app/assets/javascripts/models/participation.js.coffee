ETahi.Participation = DS.Model.extend
  user: DS.belongsTo('user')
  task: DS.belongsTo('task', polymorphic: true)
