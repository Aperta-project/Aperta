a = DS.attr

ETahi.Flow = DS.Model.extend
  emptyText: a('string')
  title: a('string')
  papers: DS.hasMany('paper')
  tasks: DS.hasMany('task', {polymorphic: true})
