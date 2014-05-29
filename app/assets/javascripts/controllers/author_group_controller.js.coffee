ETahi.AuthorGroupController = Ember.ObjectController.extend
  newAuthor: {}
  showNewAuthorForm: false

  institutions: Ember.computed.alias 'parentController.institutions'
  isEditable: Ember.computed.alias 'parentController.isEditable'

  authorSort: ['position:asc']
  sortedAuthors: Ember.computed.sort('authors', 'authorSort')

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

    changeAuthorGroup: (author, position) ->
      success = (author) => @addAuthorPosition(author)
      author.setProperties(authorGroup: @get('model'), position: position)
    changeAuthorGroup: (author) ->
      author.set('authorGroup', @get('model'))
      author.save()
