a = DS.attr
ETahi.CardThumbnail = DS.Model.extend
  title: a('string')
  taskType: a('string')
  completed: a('boolean')
  position: a('number')
  litePaper: DS.belongsTo('litePaper')
  task: DS.belongsTo('task', polymorphic: true)
