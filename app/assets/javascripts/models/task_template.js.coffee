a = DS.attr
ETahi.TaskTemplate = DS.Model.extend
  phaseTemplate: DS.belongsTo('phaseTemplate')
  journalTaskType: DS.belongsTo('journalTaskType')
  title: a('string')
  template: a()
