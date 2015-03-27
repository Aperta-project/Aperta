`import Ember from 'ember'`
`import BasePaperController from 'tahi/controllers/base-paper'` # EMBERCLI TODO - this is weird
`import TahiEditorExtensions from 'tahi-editor-extensions/index'`
`import FigureCollectionAdapter from './adapters/ve-figure-collection-adapter'`

PaperEditController = BasePaperController.extend

  needs: ['overlays/paperSubmit']

  # initialized in @setupEditor
  editor: null
  # initialized by paper/edit/view
  toolbar: null
  # used to recover a selection when returning from another context (such as figures)
  lastEditorState: null

  figuresAdapter: null

  saveState: false
  isSaving: false

  # set to true when opening an editor overlay (figures, tables)
  hasOverlay: false

  errorText: ""

  isBodyEmpty: Ember.computed 'model.body', ->
    Ember.isBlank $(@get 'model.body').text()

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

  # called by ember-cli-visualeditor/components/visual-editor (see template for hook)
  setupEditor: ( (editor) ->
    FigureNodeIndex = require('tahi-editor-extensions/figures/model/figure-label-generator')['default']
    self = @

    # register extensions
    editor.registerExtensions(TahiEditorExtensions)
    editor.registerExtension(
      afterDocumentCreated: (documentModel) ->
        figuresIndex = documentModel.getIndex('figure-nodes')
        figureLabelGenerator = new FigureNodeIndex(figuresIndex)
        documentModel.addService('figure-labels', figureLabelGenerator)
    )

    doc = editor.getDocument()
    paper = this.get('model')

    figuresAdapter = FigureCollectionAdapter.create(
      controller: @
      paper: paper
      doc: doc
    ).connect()

    # load the document
    editor.fromHtml(paper.get('body'))

    @set('editor', editor)
    @set('figuresAdapter', figuresAdapter)
    editor.removeSelection()
  )

  updateToolbar: (newState) ->
    toolbar = @get('toolbar')
    if toolbar
      toolbar.updateState(newState)
      @set('lastEditorState', newState)

  startEditing: ->
    @set('lockedBy', @currentUser)
    @get('model').save().then (paper) =>
      @connectEditor()
      @send('startEditing')
      @set('saveState', false)

  stopEditing: ->
    @set('model.body', @get('editor').toHtml())
    @set('lockedBy', null)
    @send('stopEditing')
    @disconnectEditor()
    @get('model').save().then (paper) =>
      @set('saveState', true)

  # enables handlers for document changes (saving) and selection changes (toolbar)
  connectEditor: ->
    @get('editor').connect @,
      "document-change": @onDocumentChange
      "state-changed": @updateToolbar

  disconnectEditor: ->
    @get('editor').disconnect @

  savePaper: ->
    return unless @get('model.editable')
    editor = @get('editor')
    paper = @get('model')
    manuscriptHtml = editor.toHtml()
    paper.set('body', manuscriptHtml)
    if paper.get('isDirty')
      console.log('Saving paper...')
      paper.save().then (paper) =>
        @set('saveState', true)
        @set('isSaving', false)
    else
      @set('isSaving', false)

  savePaperDebounced: ->
    @set('isSaving', true)
    Ember.run.debounce(@, @savePaper, 2000)

  onDocumentChange: ->
    doc = @get('editor').getDocument()
    # HACK: in certain moments we need to inhibit saving
    # e.g., when updating a figure URL, the server provides a new figure URL
    # leading to an unfinite loop of updates.
    # See paper/edit/ve-figure-adapter
    unless @get('inhibitSave')
      @set('saveState', false)
      @savePaperDebounced()

  willDestroy: ( ->
    @_super()
    @get('figuresAdapter').dispose()
  )

  actions:
    toggleEditing: ->
      if @get('lockedBy') #unlocking -> Allowing others to edit
        @stopEditing()
      else #locking -> Editing Paper (locking others out)
        @startEditing()

    savePaper: ->
      @savePaperDebounced()

    updateDocumentBody: (content) ->
      @set('body', content)
      false

    confirmSubmitPaper: ->
      return unless @get('allMetadataTasksCompleted')
      @get('model').save()
      @get('controllers.overlays/paperSubmit').set 'model', @get('model')
      @send 'showConfirmSubmitOverlay'


`export default PaperEditController`
