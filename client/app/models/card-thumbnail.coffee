`import DS from 'ember-data'`

a = DS.attr

CardThumbnail = DS.Model.extend
  litePaper: DS.belongsTo('litePaper')
  task: DS.belongsTo('task', polymorphic: true)

  completed: a('boolean')
  createdAt: a('string')
  position: a('number')
  taskType: a('string')
  title: a('string')

`export default CardThumbnail`
