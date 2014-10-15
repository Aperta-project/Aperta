ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  newAuthorFormVisible: false

  allAuthors: []
  _setAllAuthors: (-> @set('allAuthors', @store.all('author'))).on('init')
  authors: (-> @get('allAuthors').filterBy('paper', @get('paper'))).property('paper','allAuthors.@each.paper')
  authorSort: ['position:asc']
  sortedAuthors: Ember.computed.sort('authors', 'authorSort')

  shiftAuthorPositions: (author, newPosition)->
    oldPosition = author.get 'position'
    author.set('position', newPosition)
    author.save()

  actions:
    toggleAuthorForm: ->
      @toggleProperty 'newAuthorFormVisible'
      false

    saveNewAuthor: (newAuthorHash) ->
      newAuthorHash.position = 0
      newAuthorHash.paper = @get('paper')
      @store.createRecord('author', newAuthorHash).save()
      @toggleProperty('newAuthorFormVisible')

    saveAuthor: (author) ->
      author.save()

    removeAuthor: (author) ->
      author.destroyRecord()
