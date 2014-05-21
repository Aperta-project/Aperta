ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  newAuthor: {}
  showNewAuthorForm: false

  authors: Ember.computed.alias 'resolvedPaper.authors'

  resolvedPaper: null

  _setPaper: ( ->
    @get('paper').then (paper) =>
      @set('resolvedPaper', paper)
  ).observes('paper')

  toggleAuthorForm: ->
    @set('showNewAuthorForm', !@showNewAuthorForm)

  saveNewAuthor: ->
    @get('authors').pushObject @newAuthor
    @get('resolvedPaper').save()
    @set('newAuthor', {})
    @toggleAuthorForm()

  actions:
    toggleAuthorForm: ->
      @toggleAuthorForm()

