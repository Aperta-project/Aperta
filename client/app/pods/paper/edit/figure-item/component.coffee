`import Ember from 'ember'`
`import AttachmentThumbnailComponent from 'tahi/pods/components/attachment-thumbnail/component'`
`import TahiEditorExtensions from 'tahi-editor-extensions/index'`
`import FigureCollectionAdapter from 'tahi/pods/paper/edit/adapters/figure-collection-adapter';`

FigureItemComponent = AttachmentThumbnailComponent.extend
  attachmentType: 'figure'

  manuscriptEditor: null
  figure: Ember.computed.alias 'attachment'

  paper: null
  editor: null
  adapter: null

  label: (->
    figure = @get('figure')
    doc = @get('manuscriptEditor').getDocument();
    labels = doc.getService('figure-labels')
    return labels.getFigureLabel(figure.get('id'))
  ).property('figure', 'manuscriptEditor')

  hasPlacement: ( ->
    return !!@get('label')
  ).property('label')

  hasManuscriptSelection: (->
    manuscriptEditor = @get('manuscriptEditor')
    if manuscriptEditor
      return manuscriptEditor.getState().hasSelection();
    else
      return false
  ).property('manuscriptEditor')

  canInsert: ( ->
    return !@get('hasPlacement') and @get('hasManuscriptSelection')
  ).property('hasPlacement', 'hasManuscriptSelection')

  isEditing: false

  isSaving: Ember.computed.alias('adapter.isSaving')

  setupEditor: ( (editor) ->
    manuscriptEditor = @get('manuscriptEditor');
    # register extensions
    editor.registerExtensions(TahiEditorExtensions)
    editor.registerExtension(
      afterDocumentCreated: (documentModel) ->
        documentModel.addService('main-document',
          get: ->
            return manuscriptEditor.getDocument()
        )
        documentModel.addService('figure-labels',
          manuscriptEditor.getDocument().getService('figure-labels')
        )
    )
    paper = @get('paper')
    figure = @get('figure')
    doc = editor.getDocument()
    editor.fromHtml(figure.toHtml())
    adapter = FigureCollectionAdapter.create(
      doc: doc
      paper: paper
      editor: editor
    )
    @set('adapter', adapter)
    @set('editor', editor)
  )

  initiallyEnableEditing: ( ->
    @startEditing()
  ).on('didInsertElement')

  startEditing: ->
    editor = @get('editor')
    adapter = @get('adapter')
    unless @get('isEditing')
      @set('isEditing', true)
      editor.connect @,
        "state-changed": @onSelectionChange
      editor.enable()

  stopEditing: ->
    editor = @get('editor')
    adapter = @get('adapter')
    if @get('isEditing')
      @set('isEditing', false)
      editor.disable()
      editor.disconnect @
      @get('figure').save()

  toggleEditing: ->
    if @get('isEditing')
      @stopEditing()
    else
      @startEditing()

  dispose: ( ->
    @get('adapter').destroy()
    @get('editor').disconnect @
  ).on('willDestroyElement')

  onSelectionChange: (newState) ->
    @sendAction('updateToolbar', newState)

  actions:
    insertFigure: ->
      figure = @get('attachment');
      @sendAction('insertFigure', figure.get('id'))

    toggleStrikingImageFromCheckbox: (checkbox)->
      newValue = if checkbox.get('checked') then checkbox.get('attachment.id') else null
      @sendAction('action', newValue)

`export default FigureItemComponent`
