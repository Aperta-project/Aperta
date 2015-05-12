`import Ember from 'ember';`
`import PaperEditMixin from 'tahi/mixins/views/paper-edit';`

View = Ember.View.extend PaperEditMixin,
  toolbar: null

  propagateToolbar: ( ->
    @set('controller.toolbar', @get('toolbar'))
  ).observes('toolbar')

  _updateFigures: (->
    # HACK: unfortunately we have to wait for the UI
    # to be able to use the adapter to manipulate the VE model
    @get('controller').updateFigures()
  ).on('didInsertElement')

  updateEditorLockedState: ( ->
    editor = @get('controller.editor')
    if editor
      if @get('isEditing')
        editor.enable()
      else
        editor.disable()
  ).observes('isEditing')

  initializeEditingState: ( ->
    @updateEditorLockedState()
  ).on('didInsertElement')

  destroyEditor: ( ->
    Ember.$(document).off 'keyup.autoSave'
  ).on('willDestroyElement')

  timeoutSave: ->
    return if Ember.testing # TODO: make this injectable via visual editor lifecycle hooks
    @saveEditorChanges()
    @get('controller').send('savePaper')
    Ember.run.cancel(@short)
    Ember.run.cancel(@long)
    @short = null
    @long = null
    @keyCount = 0

  short: null
  long: null
  keyCount: 0

  saveEditorChanges: ->
    documentBody = @get('controller.editor').toHtml()
    @get('controller').send('updateDocumentBody', documentBody)

`export default View;`
