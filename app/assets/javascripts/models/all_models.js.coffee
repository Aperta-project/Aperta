a = DS.attr
ETahi.Paper = DS.Model.extend
  shortTitle: a('string')
  title: a('string')
  phases: DS.hasMany('phase')

ETahi.Phase = DS.Model.extend
  name: a('string')
  position: a('number')
  paper: DS.belongsTo('paper')
  tasks: DS.hasMany('task')

ETahi.User = DS.Model.extend
  imageUrl: a('string')
  fullName: a('string')

ETahi.Comment = DS.Model.extend
  body: a('string')
  task: DS.belongsTo('task')
