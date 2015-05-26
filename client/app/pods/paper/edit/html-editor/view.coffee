`import Ember from 'ember';`
`import PaperEditMixin from 'tahi/mixins/views/paper-edit';`

View = Ember.View.extend PaperEditMixin,

  editor: null

  propagateEditor: (->
    @set('controller.editor', @get('editor'))
  ).observes('editor')

  updateEditorLockedState: ( ->
    editor = @get('controller.editor')
    return unless editor
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
    documentBody = @get('controller').getBodyHtml()
    @get('controller').send('updateDocumentBody', documentBody)

`export default View;`
