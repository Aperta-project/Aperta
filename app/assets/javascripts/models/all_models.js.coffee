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

ETahi.Task = DS.Model.extend
  title: a('string')
  type: a('string')
  completed: a('boolean')
  role: a('string')
  body: a('string')
  messageSubject: a('string')
  comments: DS.hasMany('comment')

ETahi.User = DS.Model.extend
  imageUrl: a('string')
  name: a('string')

ETahi.Comment = DS.Model.extend
  body: a('string')
  task: DS.belongsTo('task')
