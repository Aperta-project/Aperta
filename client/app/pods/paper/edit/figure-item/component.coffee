`import Ember from 'ember'`
`import AttachmentThumbnailComponent from 'tahi/pods/components/attachment-thumbnail/component'`
`import TahiEditorExtensions from 'tahi-editor-extensions/index'`
`import VEFigureItemAdapter from '../adapters/ve-figure-item-adapter'`

FigureItemComponent = AttachmentThumbnailComponent.extend
  attachmentType: 'figure'

  manuscriptEditor: null
  figure: Ember.computed.alias 'attachment'

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

  isEditing: false

  isSaving: false

  setupEditor: ( (editor) ->
    console.log('Setting up editor for figure item in figures overlay...');
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

    figure = @get('figure');
    html = [
      '<div data-type="form" data-name="figure">',
        '<div data-type="form-entry" data-name="title" class="figure-title">',
          '<span data-type="text-input" data-name="title" class="figure-title" data-placeholder="Enter title here">', figure.get('title'), '</span>',
        '</div>',
        '<div data-type="form-entry" data-name="title" class="figure-caption">',
          '<span data-type="text-input" data-name="caption"  class="figure-caption" data-placeholder="Enter caption here">', figure.get('caption'), '</span>',
        '</div>',
      '</div>'
    ].join('')
    editor.fromHtml(html)

    # TODO: would be nice to have a more convenient find API (like selectors in DOM)
    # so that we could do something like docNode.find('form[name=figure]')
    docNode = editor.getSurfaceView().getView().getDocument().getDocumentNode()
    figureItemNode = null
    docNode.traverseBFS( (node) ->
      if node.type == 'form'
        figureItemNode = node
        #break traversal
        return false
    )
    adapter = VEFigureItemAdapter.create(
      component: @
      figure: figure
      node: figureItemNode
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
      adapter.connect()
      editor.connect @,
        "state-changed": @onSelectionChange
      editor.enable()

  stopEditing: ->
    editor = @get('editor')
    adapter = @get('adapter')
    if @get('isEditing')
      @set('isEditing', false)
      editor.disable()
      adapter.disconnect()
      editor.disconnect @
      @get('figure').save()


  toggleEditing: ->
    if @get('isEditing')
      @stopEditing()
    else
      @startEditing()

  dispose: ( ->
    @get('adapter').disconnect()
    @get('editor').disconnect @
  ).on('willDestroyElement')

  onSelectionChange: (newState) ->
    @sendAction('updateToolbar', newState)

  saveFigure: ->
    self = @
    @get('figure').save().then(->
      self.set('isSaving', false)
    )

  saveFigureDebounced: ->
    @set('isSaving', true)
    Ember.run.debounce(@, @saveFigure, 2000);

  actions:
    toggleStrikingImageFromCheckbox: (checkbox)->
      newValue = if checkbox.get('checked') then checkbox.get('attachment.id') else null
      @sendAction('action', newValue)

    insertFigure: ->
      figure = @get('attachment');
      @sendAction('insertFigure', figure.get('id'))

    saveFigure: ->
      @saveFigureDebounced()

`export default FigureItemComponent`
