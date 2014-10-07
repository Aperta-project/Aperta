ETahi.Participation = DS.Model.extend
  participant: DS.belongsTo('user')
  task: DS.belongsTo('task', polymorphic: true)
