ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  newAuthor: {}
  showNewAuthorForm: false

  authors: Ember.computed.alias 'resolvedPaper.authors'

  resolvedPaper: null

  _setPaper: ( ->
    @get('paper').then (paper) =>
      @set('resolvedPaper', paper)
  ).observes('paper')

  toggleAuthorForm: ->
    @set('showNewAuthorForm', !@showNewAuthorForm)

  saveNewAuthor: ->
    author = @store.createRecord('author', @newAuthor)
    #TODO: change this to associate with the correct author group
    author.set('authorGroup', @get('resolvedPaper.authorGroups.firstObject'))
    author.save().then (author) =>
      @set('newAuthor', {})
      @toggleAuthorForm()

  actions:
    toggleAuthorForm: ->
      @toggleAuthorForm()

    addAuthorGroup: ->
      newAuthorGroup = @store.createRecord('authorGroup', {})
      newAuthorGroup.set('paper', @get('resolvedPaper'))
      newAuthorGroup.save()

    removeAuthorGroup: ->
      ag = @get('paper.authorGroups.lastObject')
      if !ag.get('authors.length')
        ag.deleteRecord()
        ag.save()

