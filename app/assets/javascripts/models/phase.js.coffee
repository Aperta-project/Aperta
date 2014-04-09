a = DS.attr
ETahi.Phase = DS.Model.extend
  paper: DS.belongsTo('paper')
  tasks: DS.hasMany('task', {polymorphic: true})
  name: a('string')
  position: a('number')
  noTasks: Ember.computed.empty('tasks.[]')
