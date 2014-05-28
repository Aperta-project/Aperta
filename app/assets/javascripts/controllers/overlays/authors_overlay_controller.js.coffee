ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  newAuthor: {}
  showNewAuthorForm: false
  currentAuthorGroup: null
  authors: Ember.computed.alias 'resolvedPaper.authors'

  resolvedPaper: null

  _setPaper: ( ->
    @get('paper').then (paper) =>
      @set('resolvedPaper', paper)
  ).observes('paper')

  saveNewAuthor: ->
    author = @store.createRecord('author', @newAuthor)
    #TODO: change this to associate with the correct author group
    authorGroup = @get('currentAuthorGroup')
    author.set('authorGroup', authorGroup)
    author.save().then (author) =>
      authorGroup.get('authors').pushObject(author)
      @set('newAuthor', {})
      @toggleProperty('showNewAuthorForm')

  actions:
    toggleAuthorForm: (authorGroup=null) ->
      @set('currentAuthorGroup', authorGroup)
      @toggleProperty('showNewAuthorForm')
      false

    addAuthorGroup: ->
      newAuthorGroup = @store.createRecord('authorGroup', {})
      newAuthorGroup.set('paper', @get('resolvedPaper'))
      newAuthorGroup.save()

    removeAuthorGroup: ->
      ag = @get('resolvedPaper.authorGroups.lastObject')
      if !ag.get('authors.length')
        ag.destroyRecord()
