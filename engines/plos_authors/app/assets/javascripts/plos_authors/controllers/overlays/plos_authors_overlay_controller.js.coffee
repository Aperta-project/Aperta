ETahi.PlosAuthorsOverlayController = ETahi.TaskController.extend
  newAuthorFormVisible: false

  allAuthors: []
  _setAllAuthors: (-> @set('allAuthors', @store.all('plosAuthor'))).on('init')
  authors: (-> @get('allAuthors').filterBy('paper', @get('resolvedPaper'))).property('resolvedPaper','allAuthors.@each.paper')

  authorSort: ['position:asc']
  sortedAuthors: Ember.computed.sort('plosAuthors', 'authorSort')

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

    saveAuthor: (plosAuthor) ->
      plosAuthor.save()

    removeAuthor: (plosAuthor) ->
      plosAuthor.destroyRecord()
