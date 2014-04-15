a = DS.attr
ETahi.Paper = DS.Model.extend
  assignees: DS.hasMany('user')
  declarations: DS.hasMany('declaration')
  editors: DS.hasMany('user')
  figures: DS.hasMany('figure')
  journal: DS.belongsTo('journal')
  phases: DS.hasMany('phase')
  reviewers: DS.hasMany('user')

  authors: a()
  body: a('string')
  decision: a('string')
  decisionLetter: a('string')
  shortTitle: a('string')
  submitted: a('boolean')
  title: a('string')

  availableReviewers: Ember.computed.alias('journal.reviewers')
  editor: Ember.computed.alias('editors.firstObject')
  relationshipsToSerialize: ['reviewers']

  displayTitle: (->
    @get('title') || @get('shortTitle')
  ).property 'title', 'shortTitle'

  allTasks: (->
    allTasks = _.flatten @get('phases.content').mapBy('tasks.content')
  ).property('phases.@each.tasks')
