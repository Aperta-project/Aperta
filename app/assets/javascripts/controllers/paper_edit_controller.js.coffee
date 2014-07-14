#= require controllers/paper_controller
ETahi.PaperEditController = ETahi.PaperController.extend
  errorText: ""

  addAuthorsTask: (->
    this.get('tasks').findBy('type', 'AuthorsTask')
  ).property()

  showPlaceholder: Em.computed ->
    Ember.isBlank $(@get 'model.body').text()

  lockMessage: ( ->
    @get('processingMessage') || @get('userEditingMessage')
  ).property('processingMessage', 'userEditingMessage')

  processingMessage: (->
    if @get('status') is "processing"
      "Processing Manuscript"
    else
      null
  ).property('status')

  userEditingMessage: ( ->
    lockedBy = @get('lockedBy')
    if lockedBy and lockedBy isnt @getCurrentUser()
      "<span class='user-name'>#{lockedBy.get('fullName')}</span> <span>is editing</span>"
    else
      null
  ).property('lockedBy')

  locked: ( ->
    !Ember.isBlank(@get('lockMessage'))
  ).property('lockMessage')

  isEditing: (->
    lockedBy = @get('lockedBy')
    lockedBy and lockedBy is @getCurrentUser()
  ).property('lockedBy')

  canEdit: ( ->
    !@get('locked')
  ).property('locked')

  defaultBody: 'Type your manuscript here'

  actions:
    toggleEditing: ->
      if @get('lockedBy')
        @set('lockedBy', null)
      else
        @set('lockedBy', @getCurrentUser())
      @send('savePaper')

    savePaper: ->
      return unless @get('model.editable')
      @set("saveState", "Saving...")
      @get('model').save().then (paper) =>
        @set("saveState", "Saved.")

    updateDocumentBody: (documentBody) ->
      @set('body', documentBody)
      false

    confirmSubmitPaper: ->
      return unless @get('allMetadataTasksCompleted')
      @get('model').save()
      @transitionToRoute('paper.submit')
