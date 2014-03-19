a = DS.attr
ETahi.Phase = DS.Model.extend
  name: a('string')
  position: a('number')
  paper: DS.belongsTo('paper')
  tasks: DS.hasMany('task', {polymorphic: true})
  noTasks: Ember.computed.empty('tasks.[]')
