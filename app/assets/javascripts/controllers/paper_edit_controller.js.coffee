#= require controllers/base_paper_controller
ETahi.PaperEditController = ETahi.BasePaperController.extend
  needs: ['paperSubmitOverlay']
  visualEditor: null
  saveState: false

  setupVisualEditor: (->
    @set('visualEditor', ETahi.VisualEditorService.create())
  ).on("init")

  errorText: ""

  isBodyEmpty: Em.computed 'model.body', ->
    Ember.isBlank $(@get 'model.body').text()

  showPlaceholder: Em.computed 'isBodyEmpty', 'visualEditor.isCurrentlyEditing', ->
    @get('isBodyEmpty') && !@get('visualEditor.isCurrentlyEditing')

  statusMessage: Em.computed.any 'processingMessage', 'userEditingMessage', 'saveStateMessage'

  processingMessage: (->
    if @get('status') is "processing"
      "Processing Manuscript"
    else
      null
  ).property('status')

  userEditingMessage: ( ->
    lockedBy = @get('lockedBy')
    if lockedBy and lockedBy isnt @getCurrentUser()
      "<span class='edit-paper-locked-by'>#{lockedBy.get('fullName')}</span> <span>is editing</span>"
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

  saveStateDidChange: (->
    if @get('saveState')
      @setProperties
        saveStateMessage: "Saved"
        savedAt: new Date()
    else
      @setProperties
        saveStateMessage: null
        savedAt: null
  ).observes('saveState')

  actions:
    tryHidingPlaceholder: ->
      @get('visualEditor').startEditing()

    toggleEditing: ->
      if @get('lockedBy') #unlocking -> Allowing others to edit
        @set('body', @get('visualEditor.bodyHtml'))
        @set('lockedBy', null)
        @send('stopEditing')
        @get('model').save().then (paper) =>
          @set('saveState', true)
      else #locking -> Editing Paper (locking others out)
        @set('lockedBy', @getCurrentUser())
        @get('model').save().then (paper) =>
          @send('startEditing')
          @set('saveState', false)

    savePaper: ->
      return unless @get('model.editable')
      @get('model').save().then (paper) =>
        @set('saveState', true)

    updateDocumentBody: (content) ->
      @set('body', content)
      false

    confirmSubmitPaper: ->
      return unless @get('allMetadataTasksCompleted')

      @get('model').save()
      @get('controllers.paperSubmitOverlay').set 'model', @get('model')
      @send 'showConfirmSubmitOverlay'
