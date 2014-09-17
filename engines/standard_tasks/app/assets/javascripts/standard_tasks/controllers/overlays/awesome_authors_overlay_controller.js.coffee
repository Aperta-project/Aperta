ETahi.AwesomeAuthorsOverlayController = ETahi.TaskController.extend

  validationErrors: {}

  initNewAuthor: ( ->
    author = @store.createRecord('awesomeAuthor', awesomeAuthorsTask: @get('model'))
    @set('newAwesomeAuthor', author)
  ).on('didSetup')


  actions:
    saveAuthor: (author) ->
      author.save().then ((newAuthor) =>
        @initNewAuthor()),
      ((error) =>
        console.log("Hey, you probably have an invalid author but the task is marked complete.  You won't be allowed to do that soon!")
      )

   saveModel: ->
      @_super()
        .then () =>
          @set('validationErrors', {})
        .catch (error) =>
          errors = error.errors
          if errors.awesomeAuthors
            errors.awesomeAuthors.map (authorErrors) =>
              authorId = authorErrors.id
              delete authorErrors.id
              @store.find('awesomeAuthor', authorId).then (author) ->
                ETahi.camelizeKeys(authorErrors)
                author.set('validationErrors', authorErrors)
            delete errors.authors
          @set('model.completed', false)
          ETahi.camelizeKeys errors
          @set('validationErrors', errors)

