`import Ember from 'ember'`
`import TahiEditorExtensions from 'tahi-editor-extensions/index'`
`import VETableItemAdapter from '../adapters/ve-table-item-adapter'`

TableItemComponent = Ember.Component.extend

  classNameBindings: ['destroyState:_destroy', 'editState:_edit']

  manuscriptEditor: null
  editor: null
  table: null
  adapter: null

  label: (->
    table = @get('table')
    doc = @get('manuscriptEditor').getDocument();
    labels = doc.getService('table-labels')
    return labels.getFigureLabel(table.get('id'))
  ).property('table', 'manuscriptEditor')

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
    manuscriptEditor = @get('manuscriptEditor');
    # register extensions
    editor.registerExtensions(TahiEditorExtensions)
    editor.registerExtension(
      afterDocumentCreated: (documentModel) ->
        documentModel.addService('main-document',
          get: ->
            return manuscriptEditor.getDocument()
        )
        documentModel.addService('table-labels',
          manuscriptEditor.getDocument().getService('table-labels')
        )
    )

    table = @get('table');
    editor.fromHtml(table.toHtml())

    docNode = editor.getDocumentNode()
    tableItemNode = null
    docNode.traverseBFS( (node) ->
      if node.type == 'figure'
        tableItemNode = node
        #break traversal
        return false
    )
    adapter = VETableItemAdapter.create(
      component: @
      table: table
      node: tableItemNode
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
      @get('table').save()

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

  saveTable: ->
    @get('table').save().then(=>
      @set('isSaving', false)
    )

  saveTableDebounced: ->
    @set('isSaving', true)
    Ember.run.debounce(@, @saveTable, 2000);

  actions:
    insertTable: ->
      table = @get('table');
      @sendAction('insertTable', table.get('id'))

    saveTable: ->
      @saveTableDebounced()

    cancelDestroyAttachment: -> @set 'destroyState', false

    confirmDestroyAttachment: -> @set 'destroyState', true

    destroyTable: ->
      @$().fadeOut 250, =>
        @sendAction 'destroyTable', @get('table')


`export default TableItemComponent`
