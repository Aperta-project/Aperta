`import Ember from 'ember';`
`import TahiEditorExtensions from 'tahi-editor-extensions/index';`
`import TableCollectionAdapter from 'tahi/pods/paper/edit/adapters/table-collection-adapter';`

TableItemComponent = Ember.Component.extend

  classNameBindings: ['destroyState:_destroy', 'editState:_edit']

  paper: null
  table: null

  manuscriptEditor: null
  editor: null
  adapter: null

  label: (->
    table = @get('table')
    doc = @get('manuscriptEditor').getDocument()
    labels = doc.getService('table-labels')
    return labels.getFigureLabel(table.get('id'))
  ).property('table', 'manuscriptEditor')

  hasPlacement: ( ->
    !!@get('label')
  ).property('label')

  hasManuscriptSelection: (->
    manuscriptEditor = @get('manuscriptEditor')
    if manuscriptEditor
      return manuscriptEditor.getState().hasSelection()
    else
      return false
  ).property('manuscriptEditor')

  canInsert: ( ->
    return !@get('hasPlacement') and @get('hasManuscriptSelection')
  ).property('hasPlacement', 'hasManuscriptSelection')

  isEditing: false

  isSaving: Ember.computed.alias('adapter.isSaving')

  setupEditor: ( (editor) ->
    manuscriptEditor = @get('manuscriptEditor')
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
    paper = @get('paper')
    table = @get('table')
    editor.fromHtml(table.toHtml())
    doc = editor.getDocument()
    adapter = TableCollectionAdapter.create(
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
    unless @get('isEditing')
      @set('isEditing', true)
      editor.connect @,
        "state-changed": @onSelectionChange
      editor.enable()

  stopEditing: ->
    editor = @get('editor')
    if @get('isEditing')
      @set('isEditing', false)
      editor.disable()
      editor.disconnect @
      @get('table').save()

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
    insertTable: ->
      table = @get('table')
      @sendAction('insertTable', table.get('id'))

    cancelDestroyTable: -> @set 'destroyState', false

    confirmDestroyTable: -> @set 'destroyState', true

    destroyTable: ->
      @$().fadeOut 250, =>
        @sendAction 'destroyTable', @get('table')


`export default TableItemComponent`
