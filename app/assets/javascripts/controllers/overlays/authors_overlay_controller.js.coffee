ETahi.AuthorsOverlayController = ETahi.TaskController.extend
  actions:
    addNewAuthor: ->
      # prevents multiple new user forms from being generated
      @get('authors').pushObject isEditing: true unless @get('authors.lastObject')?.isEditing

    saveNewAuthor: ->
      Ember.set @get('authors.lastObject'), 'isEditing', false

      newAuthors = _.map @get('authors'), (author) ->
          author.first_name = author.firstName
          author.last_name = author.lastName
          delete author.isEditing
          delete author.firstName
          delete author.lastName
          author

      paper = @get('paper')
      paper.set 'authors', JSON.stringify(newAuthors)
      paper.save()
