`import DS from 'ember-data'`

a = DS.attr

JournalTaskType = DS.Model.extend

  journal: DS.belongsTo('journal')

  title: a('string')
  role: a('string')
  kind: a('string')

`export default JournalTaskType`
