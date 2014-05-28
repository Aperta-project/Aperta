ETahi.AuthorGroupController = Ember.ObjectController.extend
  showNewAuthorForm: false

  institutions: Ember.computed.alias 'parentController.institutions'
  isEditable: Ember.computed.alias 'parentController.isEditable'

  actions:
    toggleAuthorForm: (authorGroup=null) ->
      @set('currentAuthorGroup', authorGroup)
      @toggleProperty('showNewAuthorForm')
      false

    saveNewAuthor: (newAuthor) ->
      author = @store.createRecord('author', newAuthor)
      author.set('authorGroup', @get('model'))
      author.save().then (author) =>
        @toggleProperty('showNewAuthorForm')
