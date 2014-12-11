`import DS from 'ember-data'`

a = DS.attr

Phase = DS.Model.extend

  paper: DS.belongsTo('paper')
  tasks: DS.hasMany('task', {polymorphic: true, inverse: 'phase'})

  name: a('string')
  position: a('number')

  noTasks: Ember.computed.empty('tasks.[]')

`export default Phase`
