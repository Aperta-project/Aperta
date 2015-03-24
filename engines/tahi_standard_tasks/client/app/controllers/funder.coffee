`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`
`import SavesDelayed from 'tahi/mixins/controllers/saves-delayed'`

FunderController = Ember.ObjectController.extend SavesDelayed,
  allAuthors: null
  fundedAuthors: Em.computed.alias('model.authors')
  addingAuthor: null,

  uniqueName: (->
    "funder-had-influence-#{Utils.generateUUID()}"
  ).property()

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

`export default FunderController`
