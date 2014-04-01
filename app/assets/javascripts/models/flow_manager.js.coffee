a = DS.attr

ETahi.Flow = DS.Model.extend
  emptyText: a('string')
  title: a('string')
  papers: DS.hasMany('paper')
  tasks: (->
    allTasks = _.flatten @get('papers').mapBy('allTasks')
  ).property('phases.@each.tasks')
