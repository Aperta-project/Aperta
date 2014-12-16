`import Ember from 'ember'`
`import BasePaperController from 'tahi/controllers/base-paper'` # EMBERCLI TODO - this is weird
`import VisualEditor from 'tahi/services/visual-editor'`

PaperEditController = BasePaperController.extend
  needs: ['overlays/paperSubmit']
  visualEditor: null
  saveState: false

  setupVisualEditor: (->
    @set('visualEditor', VisualEditor.create())
  ).on("init")

  errorText: ""

  isBodyEmpty: Ember.computed 'model.body', ->
    Ember.isBlank $(@get 'model.body').text()

  showPlaceholder: Ember.computed 'isBodyEmpty', 'visualEditor.isCurrentlyEditing', ->
    @get('isBodyEmpty') && !@get('visualEditor.isCurrentlyEditing')

  statusMessage: Ember.computed.any 'processingMessage', 'userEditingMessage', 'saveStateMessage'

  processingMessage: (->
    if @get('status') is "processing"
      "Processing Manuscript"
    else
      null
  ).property('status')

  userEditingMessage: ( ->
    lockedBy = @get('lockedBy')
    if lockedBy and lockedBy isnt @currentUser
      "<span class='edit-paper-locked-by'>#{lockedBy.get('fullName')}</span> <span>is editing</span>"
    else
      null
  ).property('lockedBy')

  locked: ( ->
    !Ember.isBlank(@get('processingMessage') || @get('userEditingMessage'))
  ).property('processingMessage', 'userEditingMessage')

  isEditing: (->
    lockedBy = @get('lockedBy')
    lockedBy and lockedBy is @currentUser
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
      if @get('lockedBy') #unlocking
        @set('body', @get('visualEditor.bodyHtml'))
        @set('lockedBy', null)
        @send('stopEditing')
        @get('model').save().then (paper) =>
          @set('saveState', true)
      else #locking
        @set('lockedBy', @currentUser)
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

`export default PaperEditController`
