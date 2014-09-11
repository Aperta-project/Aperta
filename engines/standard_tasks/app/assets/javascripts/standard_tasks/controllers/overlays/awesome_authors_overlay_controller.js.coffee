ETahi.AwesomeAuthorsOverlayController = ETahi.TaskController.extend
  resolvedPaper: null

  _setPaper: ( ->
    @get('paper').then (paper) =>
      @set('resolvedPaper', paper)
  ).observes('paper')

  lastAuthorGroup: Ember.computed.alias('resolvedPaper.authorGroups.lastObject')
  canDeleteLastGroup: Ember.computed.empty('lastAuthorGroup.authors.[]')

  actions:
    saveAuthor: ->
      @sendAction('save', @get('awesomeAuthor'))
      @set('showEditAuthorForm', false)

