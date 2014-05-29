ETahi.AuthorGroupController = Ember.ObjectController.extend
  newAuthor: {}
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

  actions:
    toggleAuthorForm: (authorGroup=null) ->
      @set('currentAuthorGroup', authorGroup)
      @toggleProperty('showNewAuthorForm')
      false

    saveNewAuthor: ->
      author = @store.createRecord('author', @newAuthor)
      author.set('authorGroup', @get('model'))
      author.save().then (author) =>
        @get('authors').pushObject(author)
        @set('newAuthor', {})
        @toggleProperty('showNewAuthorForm')

    saveAuthor: (author) ->
      author.save()

    removeAuthor: (author) ->
      author.destroyRecord().then (author) =>
        @updateAuthorPositions(author, @get('authors'), 'remove')

    changeAuthorGroup: (author, position) ->
      @updateAuthorPositions(author, author.get('authorGroup.authors'), 'remove')

      author.set('authorGroup', @get('model'))
      author.set('position', position)
      author.save()

      @updateAuthorPositions(author, @get('authors'), 'add')
