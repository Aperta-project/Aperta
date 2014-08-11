a = DS.attr
ETahi.TaskTemplate = DS.Model.extend
  title: a('string')
  phaseTemplate: DS.belongsTo('phaseTemplate')
  journalTaskType: DS.belongsTo('journalTaskType')
