ETahi.AuthorGroupController = Ember.ObjectController.extend
  showNewAuthorForm: false

  institutions: Ember.computed.alias 'parentController.institutions'
  isEditable: Ember.computed.alias 'parentController.isEditable'

  authorSort: ['position:asc']
  sortedAuthors: Ember.computed.sort('authors', 'authorSort')

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
    toggleAuthorForm: (authorGroup=null) ->
      @set('currentAuthorGroup', authorGroup)
      @toggleProperty('showNewAuthorForm')
      false

    changeAuthorGroup: (author, newPosition) ->
      if author.get('authorGroup') == @get('model')
        @shiftAuthorPositions(author, @get('model.authors'), author.get('position'), newPosition)
      else
        @updateAuthorPositions(author, author.get('authorGroup.authors'), 'remove')
        author.set('authorGroup', @get('model'))
        author.set('position', newPosition)
        author.save()
        @updateAuthorPositions(author, @get('authors'), 'add')
