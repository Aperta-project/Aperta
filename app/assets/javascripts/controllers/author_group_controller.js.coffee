ETahi.AuthorGroupController = Ember.ObjectController.extend
  newAuthor: {}
  showNewAuthorForm: false

  institutions: Ember.computed.alias 'parentController.institutions'
  isEditable: Ember.computed.alias 'parentController.isEditable'

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

    changeAuthorGroup: (author) ->
      author.set('authorGroup', @get('model'))
      author.save()
