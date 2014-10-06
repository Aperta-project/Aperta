ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  newAuthorFormVisible: false
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

  shiftAuthorPositions: (author, newPosition)->
    oldPosition = author.get 'position'

    if oldPosition < newPosition
      newPosition = newPosition - 1
      relevantAuthors = @get('authors').filter (a)->
        a != author && (a.get('position') > oldPosition) && (a.get('position') <= newPosition)
      relevantAuthors.invoke 'decrementProperty', 'position'
    else
      relevantAuthors = @get('authors').filter (a)->
        a != author && (a.get('position') < oldPosition) && (a.get('position') >= newPosition)
      relevantAuthors.invoke 'incrementProperty', 'position'

    author.set('position', newPosition)
    author.save()

  actions:
    toggleAuthorForm: ->
      @toggleProperty 'newAuthorFormVisible'
      false

    saveNewAuthor: (newAuthorHash) ->
      newAuthorHash.setPosition = 0
      newAuthorHash.position    = 0
      newAuthorHash.paper = @get 'resolvedPaper'
      @store.createRecord('author', newAuthorHash).save()
      @toggleProperty 'newAuthorFormVisible'

    saveAuthor: (author) ->
      author.save()

    removeAuthor: (author) ->
      author.destroyRecord()
