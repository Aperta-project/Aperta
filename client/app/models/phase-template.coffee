`import Ember from 'ember'`
`import DS from 'ember-data'`

a = DS.attr

PhaseTemplate = DS.Model.extend

  manuscriptManagerTemplate: DS.belongsTo('manuscriptManagerTemplate')
  taskTemplates: DS.hasMany('taskTemplate')

  name: a('string')
  position: a('number')

  noTasks: Ember.computed.empty('taskTemplates')

`export default PhaseTemplate`

