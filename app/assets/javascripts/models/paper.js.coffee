a = DS.attr
ETahi.Paper = DS.Model.extend
  shortTitle: a('string')
  title: a('string')
  assignees: DS.hasMany('assignee')
  phases: DS.hasMany('phase')
  declarations: DS.hasMany('declaration')
  reviewers: DS.hasMany('user')
  availableReviewers: Ember.computed.alias('journal.reviewers')
  editors: DS.hasMany('user')
  journal: DS.belongsTo('journal')
  figures: DS.hasMany('figure')
  authors: a('string')
  authorsArray: (->
    authors = JSON.parse @get('authors')
    _.each authors, (a) ->
      a.firstName = a.first_name
      a.lastName = a.last_name
      delete a.first_name
      delete a.last_name
  ).property 'authors'

  displayTitle: (->
    if @get('title.length') > 0
      @get('title')
    else
      @get 'shortTitle'
  ).property 'title', 'shortTitle'
