a = DS.attr
ETahi.Paper = DS.Model.extend
  shortTitle: a('string')
  title: a('string')
  decision: a('string')
  decisionLetter: a('string')
  assignees: DS.hasMany('assignee')
  phases: DS.hasMany('phase')
  declarations: DS.hasMany('declaration')
  reviewers: DS.hasMany('user')
  availableReviewers: Ember.computed.alias('journal.reviewers')
  editors: DS.hasMany('user')
  admin: DS.belongsTo('assignee')
  journal: DS.belongsTo('journal')
  figures: DS.hasMany('figure')
  authors: a()

  displayTitle: (->
    if @get('title.length') > 0
      @get('title')
    else
      @get 'shortTitle'
  ).property 'title', 'shortTitle'
