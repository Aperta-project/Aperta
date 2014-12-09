ETahi.CommonFlowAttrs = Ember.Mixin.create
  litePapers: DS.hasMany('litePaper')
  tasks: DS.hasMany('cardThumbnail')
  title: DS.attr('string')
  flowId: DS.attr('number')
