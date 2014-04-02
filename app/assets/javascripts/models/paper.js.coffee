a = DS.attr
ETahi.Paper = DS.Model.extend
  shortTitle: a('string')
  title: a('string')
  decision: a('string')
  decisionLetter: a('string')
  assignees: DS.hasMany('user')
  phases: DS.hasMany('phase')
  declarations: DS.hasMany('declaration')
  reviewers: DS.hasMany('user')
  availableReviewers: Ember.computed.alias('journal.reviewers')
  editors: DS.hasMany('user')
  journal: DS.belongsTo('journal')
  figures: DS.hasMany('figure')
  authors: a()

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property 'title', 'shortTitle'

  editor: Ember.computed.alias('editors.firstObject')

  allTasks: (->
    allTasks = _.flatten @get('phases.content').mapBy('tasks.content')
  ).property('phases.@each.tasks')

