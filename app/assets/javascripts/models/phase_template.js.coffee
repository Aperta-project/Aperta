a = DS.attr
ETahi.PhaseTemplate = DS.Model.extend
  name: a('string')
  manuscriptManagerTemplate: DS.belongsTo('manuscriptManagerTemplate')
  taskTemplates: DS.hasMany('taskTemplate')
