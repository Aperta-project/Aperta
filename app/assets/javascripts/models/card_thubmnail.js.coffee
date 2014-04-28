a = DS.attr
ETahi.CardThumbnail = DS.Model.extend
  title: a('string')
  taskType: a('string')
  completed: a('boolean')
  position: a('number')
  paper: DS.belongsTo('litePaper')
  task: DS.belongsTo('task', polymorphic: true)
  flow: DS.belongsTo('flow')
  isMessage: Ember.computed.equal('taskType', 'MessageTask')
