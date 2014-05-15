#= require controllers/paper_controller
ETahi.PaperEditController = ETahi.PaperController.extend
  errorText: ""
  addAuthorsTask: (->
    this.get('tasks').findBy('type', 'AuthorsTask')
  ).property()

  body: ((key, value) ->
    if arguments.length > 1 && value != @get('defaultBody')
      @set('model.body', value)

    modelBody = @get('model.body')
    if Ember.isBlank(modelBody)
      @get('defaultBody')
    else
      modelBody
  ).property('model.body')

  defaultBody: 'Type your manuscript here'
