`import DS from 'ember-data'`

Participation = DS.Model.extend
  user: DS.belongsTo('user')
  task: DS.belongsTo('task', polymorphic: true)

`export default Participation`
