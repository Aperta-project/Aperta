#= require controllers/paper_controller
ETahi.PaperEditController = ETahi.PaperController.extend
  visualEditor: null

  setupVisualEditor: (->
    @set('visualEditor', ETahi.VisualEditorService.create())
  ).on("init")

  errorText: ""

  addAuthorsTask: (->
    this.get('tasks').findBy('type', 'AuthorsTask')
  ).property()

  showPlaceholder: ( ->
    Ember.isBlank $(@get 'model.body').text()
  ).property('model.body')

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
        @set('body', @get('visualEditor.bodyHtml'))
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

    updateDocumentBody: (content) ->
      @set('body', content)
      false

    confirmSubmitPaper: ->
      return unless @get('allMetadataTasksCompleted')
      @get('model').save()
      @transitionToRoute('paper.submit')
