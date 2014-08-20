a = DS.attr
ETahi.JournalTaskType = DS.Model.extend
  title: a('string')
  role: a('string')
  journal: DS.belongsTo('journal')
  taskType: DS.belongsTo('taskType')
