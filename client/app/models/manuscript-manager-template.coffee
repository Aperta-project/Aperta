`import DS from 'ember-data'`

a = DS.attr

ManuscriptManagerTemplate = DS.Model.extend

  journal: DS.belongsTo('adminJournal')
  phaseTemplates: DS.hasMany('phaseTemplate')

  paperType: a('string')

`export default ManuscriptManagerTemplate`
