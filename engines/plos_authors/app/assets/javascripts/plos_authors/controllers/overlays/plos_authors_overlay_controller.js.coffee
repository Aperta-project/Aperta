ETahi.PlosAuthorsOverlayController = ETahi.TaskController.extend
  newAuthorFormVisible: false

  allAuthors: []
  _setAllAuthors: (-> @set('allAuthors', @store.all('plosAuthor'))).on('init')
  authors: (-> @get('allAuthors').filterBy('paper', @get('resolvedPaper'))).property('resolvedPaper','allAuthors.@each.paper')

  authorSort: ['position:asc']
  sortedAuthors: Ember.computed.sort('plosAuthors', 'authorSort')
  sortedAuthorsWithErrors: (->
    @get('sortedAuthors').map (author) =>
      Ember.Object.create
        author: author
        errors: @associatedErrors(author)
  ).property('sortedAuthors.@each', 'validationErrors')

  shiftAuthorPositions: (author, newPosition)->
    oldPosition = author.get 'position'
    author.set('position', newPosition)
    author.save()

  actions:
    toggleAuthorForm: ->
      @toggleProperty 'newAuthorFormVisible'
      false

    saveNewAuthor: (newAuthorHash) ->
      Ember.merge newAuthorHash,
        paper: @get('paper')
        plosAuthorsTask: @get('model')
        position: 0
      @store.createRecord('plosAuthor', newAuthorHash).save()
      @toggleProperty('newAuthorFormVisible')

    saveAuthor: (plosAuthor) ->
      @clearErrors(plosAuthor)
      plosAuthor.save()


    removeAuthor: (plosAuthor) ->
      plosAuthor.destroyRecord()
