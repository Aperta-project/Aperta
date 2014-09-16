ETahi.AwesomeAuthorsOverlayController = ETahi.TaskController.extend

  initNewAuthor: ( ->
    author = @store.createRecord('awesomeAuthor', awesomeAuthorsTask: @get('model'))
    @set('newAwesomeAuthor', author)
  ).on('didSetup')

  actions:
    saveAuthor: (author) ->
      author.save().then ((newAuthor) =>
        @initNewAuthor()),
      ((error) => debugger)

