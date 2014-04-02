a = DS.attr

ETahi.Flow = DS.Model.extend
  papers: DS.hasMany('paper')
  tasks: DS.hasMany('task', {polymorphic: true})
  emptyText: a('string')
  paperMap: a()
  title: a('string')
