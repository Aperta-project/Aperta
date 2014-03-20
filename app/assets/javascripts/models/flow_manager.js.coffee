a = DS.attr
ETahi.FlowManager = DS.Model.extend
  flows: DS.hasMany('flow')

ETahi.Flow = Em.Object.extend()
# emptyText: a('string')
# title: a('string')
# paperProfiles: DS.hasMany('paperProfile')

ETahi.PaperProfile = DS.Model.extend
  title: a('string')
  tasks: DS.hasMany('tasks')
