a = DS.attr

ETahi.ManuscriptManagerTemplate = DS.Model.extend
  paperType: a('string')
  journal: DS.belongsTo('adminJournal')
  phaseTemplates: DS.hasMany('phaseTemplate')

