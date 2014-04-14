a = DS.attr

ETahi.Flow = DS.Model.extend
  papers: DS.hasMany('litePaper')
  tasks: DS.hasMany('cardThumbnail')
  emptyText: a('string')
  title: a('string')
