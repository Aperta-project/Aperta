ETahi.FunderController = Ember.ObjectController.extend ETahi.SavesDelayed,
  allAuthors: null
  fundedAuthors: Em.computed.alias('model.authors')
  addingAuthor: null

  initAuthors: (->
    @set('allAuthors', @get('task.paper.authors'))
  ).on('init').observes('task.paper.authors')

  actions:
    funderDidChange: ->
      #saveModel is implemented in ETahi.SavesDelayed
      @send('saveModel')

    startAddingAuthor: ->
      author = @store.createRecord('author', paper: @get('task.paper'), position: 0)
      @set('addingAuthor', author)

    finishAddingAuthor: ->
      author = @get("addingAuthor")
      if author?.get("firstName") && author?.get("lastName")
        author.save().then =>
          @get('allAuthors').pushObject(author)
          @get('fundedAuthors').pushObject(author)
          @set('addingAuthor', null)

    cancelAddingAuthor: ->
      @get('addingAuthor').deleteRecord()
      @set('addingAuthor', null)

    removeFunder: ->
      @get('model').destroyRecord()
