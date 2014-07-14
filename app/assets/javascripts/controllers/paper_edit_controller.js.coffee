#= require controllers/paper_controller
ETahi.PaperEditController = ETahi.PaperController.extend
  errorText: ""

  addAuthorsTask: (->
    this.get('tasks').findBy('type', 'AuthorsTask')
  ).property()

  showPlaceholder: Em.computed ->
    Ember.isBlank $(@get 'model.body').text()

  statusMessage: ( ->
    @get('processingMessage') || @get('userEditingMessage') || @get('saveState')
  ).property('processingMessage', 'userEditingMessage', 'saveState')

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
    !Ember.isBlank(@get('processingMessage') || @get('userEditingMessage'))
  ).property('processingMessage', 'userEditingMessage')

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
      @get('model').save().then (paper) =>
        @setProperties
          saveState: null
          savedAt: null

    savePaper: ->
      return unless @get('model.editable')
      @get('model').save().then (paper) =>
        @setProperties
          saveState: "Saved"
          savedAt: new Date()

    updateDocumentBody: (documentBody) ->
      @set('body', documentBody)
      false

    confirmSubmitPaper: ->
      return unless @get('allMetadataTasksCompleted')
      @get('model').save()
      @transitionToRoute('paper.submit')
