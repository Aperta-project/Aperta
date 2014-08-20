a = DS.attr
ETahi.TaskTemplate = DS.Model.extend
  phaseTemplate: DS.belongsTo('phaseTemplate')
  journalTaskType: DS.belongsTo('journalTaskType')
  title: Em.computed.oneWay('journalTaskType.title')
