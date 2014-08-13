ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  resolvedPaper: null
  validationErrors: {}

  _setPaper: ( ->
    @get('paper').then (paper) =>
      @set('resolvedPaper', paper)
  ).observes('paper')

  lastAuthorGroup: Ember.computed.alias('resolvedPaper.authorGroups.lastObject')
  canDeleteLastGroup: Ember.computed.empty('lastAuthorGroup.authors.[]')

  saveModel: ->
    @_super()
      .then () =>
        @set('validationErrors', {})
        @get('resolvedPaper.authorGroups').map (grp) ->
          grp.get('authors').map (author) ->
            author.set('validationErrors', {})
      .catch (error) =>
        @set('saveInFlight', false)
        errors = error.errors
        if errors.authors
          errors.authors.map (authorErrors) =>
            authorId = authorErrors.id
            delete authorErrors.id
            @store.find('author', authorId).then (author) ->
              ETahi.camelizeKeys authorErrors
              author.set('validationErrors', authorErrors)
          delete errors.authors
        @set('model.completed', false)
        ETahi.camelizeKeys errors
        @set('validationErrors', errors)

  actions:
    addAuthorGroup: ->
      newAuthorGroup = @store.createRecord('authorGroup')
      newAuthorGroup.set('paper', @get('resolvedPaper'))
      newAuthorGroup.save()

    removeAuthorGroup: ->
      if @get('canDeleteLastGroup')
        @get('lastAuthorGroup').destroyRecord()
