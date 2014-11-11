ETahi.CommonFlowAttrs = Ember.Mixin.create
  litePapers: DS.hasMany('litePaper')
  tasks: DS.hasMany('cardThumbnail')
  emptyText: DS.attr('string')
  title: DS.attr('string')
