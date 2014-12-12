`import DS from 'ember-data'`

a = DS.attr

TaskTemplate = DS.Model.extend

  phaseTemplate: DS.belongsTo('phaseTemplate')
  journalTaskType: DS.belongsTo('journalTaskType')

  title: a('string')
  template: a()

`export default TaskTemplate`
