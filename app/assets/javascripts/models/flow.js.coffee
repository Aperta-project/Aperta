a = DS.attr

ETahi.Flow = DS.Model.extend
  litePapers: DS.hasMany('litePaper')
  tasks: DS.hasMany('cardThumbnail')
  emptyText: a('string')
  title: a('string')
