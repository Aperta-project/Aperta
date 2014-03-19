a = DS.attr
ETahi.Paper = DS.Model.extend
  shortTitle: a('string')
  title: a('string')
  assignees: DS.hasMany('assignee')
  phases: DS.hasMany('phase')

ETahi.Phase = DS.Model.extend
  name: a('string')
  position: a('number')
  paper: DS.belongsTo('paper')
  tasks: DS.hasMany('task', {polymorphic: true})
  noTasks: Ember.computed.empty('tasks.[]')

ETahi.User = DS.Model.extend
  imageUrl: a('string')
  fullName: a('string')

ETahi.Assignee = ETahi.User.extend()

ETahi.Comment = DS.Model.extend
  body: a('string')
  task: DS.belongsTo('task')
