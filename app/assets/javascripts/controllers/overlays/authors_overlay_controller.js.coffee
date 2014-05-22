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
    author = @store.createRecord('author', @newAuthor)
    author.set('paper', @get('resolvedPaper'))
    author.save().then (author) =>
      @set('newAuthor', {})
      @toggleAuthorForm()

  actions:
    toggleAuthorForm: ->
      @toggleAuthorForm()

