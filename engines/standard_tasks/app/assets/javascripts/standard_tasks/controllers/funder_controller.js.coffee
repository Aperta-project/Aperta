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
      group = @get('task.paper.authorGroups.firstObject')
      author = @store.createRecord('author', authorGroup: group, position: 1)
      group.get('authors').pushObject(author)
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
