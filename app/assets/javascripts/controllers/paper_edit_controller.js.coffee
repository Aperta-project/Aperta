#= require controllers/paper_controller
ETahi.PaperEditController = ETahi.PaperController.extend
  errorText: ""
  addAuthorsTask: (->
    this.get('tasks').findBy('type', 'AuthorsTask')
  ).property()

  showPlaceholder: Em.computed ->
    Ember.isBlank $(@get 'model.body').text()

  isProcessing: ( ->
    @get('status') is "processing"
  ).property('status')

  lockMessage: ( ->
    "Processing Manuscript"
  ).property('status')

  locked: ( ->
    @get('isProcessing')
  ).property('status')

  defaultBody: 'Type your manuscript here'

  actions:
    savePaper: ->
      return unless @get('model.editable')
      @set("saveState", "Saving...")
      @get('model').save().then (paper) =>
        @set("saveState", "Saved.")
