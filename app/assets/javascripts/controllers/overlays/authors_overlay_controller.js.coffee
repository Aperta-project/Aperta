ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  showNewAuthorForm: false
  resolvedPaper: null

  _setPaper: ( ->
    @get('paper').then (paper) =>
      @set('resolvedPaper', paper)
  ).observes('paper')

  allAuthors: []

  _setAllAuthors: (-> @set('allAuthors', @store.all('author'))).on('init')
  authors: (-> @get('allAuthors').filterBy('paper', @get('resolvedPaper'))).property('resolvedPaper','allAuthors.@each.paper')
  authorSort: ['position:asc']
  sortedAuthors: Ember.computed.sort('authors', 'authorSort')

  actions:
    toggleAuthorForm: ->
      @toggleProperty('showNewAuthorForm')
      false

    saveNewAuthor: (newAuthor) ->
      @toggleProperty('showNewAuthorForm')
      newAuthor.setPosition = 0
      newAuthor.position    = 0
      newAuthor.paper = @get 'resolvedPaper'
      author = @store.createRecord('author', newAuthor)
      author.save()

    saveAuthor: (author) ->
      author.save()

    removeAuthor: (author) ->
      author.destroyRecord()
