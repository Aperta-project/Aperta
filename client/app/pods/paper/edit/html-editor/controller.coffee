`import Ember from 'ember';`
`import PaperBaseMixin from 'tahi/mixins/controllers/paper-base';`
`import PaperEditMixin from 'tahi/mixins/controllers/paper-edit';`
`import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';`
`import TahiEditorExtensions from 'tahi-editor-extensions/index';`
`import VeExtensions from 'tahi-editor-ve/ve/index';`
`import FigureCollectionAdapter from 'tahi/pods/paper/edit/adapters/figure-collection-adapter';`
`import TableCollectionAdapter from 'tahi/pods/paper/edit/adapters/table-collection-adapter';`

Controller = Ember.Controller.extend PaperBaseMixin, PaperEditMixin, DiscussionsRoutePathsMixin,
  subRouteName: 'edit'

  # initialized by paper/edit/view
  toolbar: null

  # used to recover a selection when returning from another context (such as figures)
  isEditing: Ember.computed.alias('lockedByCurrentUser')
  hasOverlay: false
  editorComponent: 'tahi-editor-ve'

  paperBodyDidChange: ( ->
    unless @get('lockedByCurrentUser')
      @updateEditor()
  ).observes('model.body')

  startEditing: ->
    @set('model.lockedBy', @currentUser)
    @get('model').save().then (paper) =>
      @connectEditor()
      @send('startEditing')
      @set('saveState', false)

  stopEditing: ->
    @set('model.body', @get('editor').getBodyHtml())
    @set('model.lockedBy', null)
    @send('stopEditing')
    @disconnectEditor()
    @get('model').save().then (paper) =>
      @set('saveState', true)

  updateEditor: ->
    editor = @get('editor')
    if editor
      editor.update()

  savePaper: ->
    return unless @get('model.editable')
    editor = @get('editor')
    paper = @get('model')
    manuscriptHtml = editor.getBodyHtml()
    paper.set('body', manuscriptHtml)
    if paper.get('isDirty')
      paper.save().then (paper) =>
        @set('saveState', true)
        @set('isSaving', false)
    else
      @set('isSaving', false)

  connectEditor: ->
    @get('editor').connect()

  disconnectEditor: ->
    @get('editor').disconnect()

`export default Controller;`
