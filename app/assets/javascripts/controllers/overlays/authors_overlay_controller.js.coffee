ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  showNewAuthorForm: false
  resolvedPaper: null

  _setPaper: ( ->
    @get('paper').then (paper) =>
      @set('resolvedPaper', paper)
  ).observes('paper')

  authorSort: ['position:asc']
  sortedAuthors: Ember.computed.sort('resolvedPaper.authors', 'authorSort')

  updateAuthorPositions: (author, authorList, operation)->
    relevantAuthors = authorList.filter (a)->
      a != author && a.get('position') >= author.get('position')

    op = {add: 'incrementProperty', remove: 'decrementProperty'}
    relevantAuthors.invoke(op[operation], 'position')

  shiftAuthorPositions: (author, authorList, oldPosition, newPosition)->
    if oldPosition < newPosition
      newPosition = newPosition - 1
      relevantAuthors = authorList.filter (a)->
        a != author && (a.get('position') > oldPosition) && (a.get('position') <= newPosition)
      relevantAuthors.invoke('decrementProperty', 'position')

    else
      relevantAuthors = authorList.filter (a)->
        a != author && (a.get('position') < oldPosition) && (a.get('position') >= newPosition)
      relevantAuthors.invoke('incrementProperty', 'position')

    author.set('position', newPosition)
    author.save()

  actions:
    toggleAuthorForm: ->
      @toggleProperty('showNewAuthorForm')
      false

    saveNewAuthor: (newAuthor) ->
      newAuthor.position = @get('authors.length') + 1
      author = @store.createRecord('author', newAuthor)
      author.save().then (author) =>
        @toggleProperty('showNewAuthorForm')

    saveAuthor: (author) ->
      author.save()

    removeAuthor: (author) ->
      author.destroyRecord().then (author) =>
        @updateAuthorPositions(author, @get('authors'), 'remove')
