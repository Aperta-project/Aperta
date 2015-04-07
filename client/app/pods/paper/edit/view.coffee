`import Ember from 'ember'`
`import RedirectsIfEditable from 'tahi/mixins/views/redirects-if-editable'`

PaperEditView = Ember.View.extend RedirectsIfEditable,

  classNames: ["edit-paper"]

  # initialized by component helper {{visual-editor}}
  editor: null

  # initialized by component helper {{visual-editor-toolbar}}
  toolbar: null

  locked: Ember.computed.alias 'controller.locked'
  isEditing: Ember.computed.alias 'controller.isEditing'

  subNavVisible: false
  downloadsVisible: false
  contributorsVisible: false

  propagateToolbar: ( ->
    @set('controller.toolbar', @get('toolbar'))
  ).observes('toolbar')

  setBackgroundColor: (->
    $('html').addClass 'matte'
  ).on('didInsertElement')

  resetBackgroundColor: (->
    $('html').removeClass 'matte'
  ).on('willDestroyElement')

  applyManuscriptCss:(->
    $('#paper-body').attr('style', @get('controller.model.journal.manuscriptCss'))
  ).on('didInsertElement')

  updateEditorLockedState: ( ->
    editor = @get("controller.editor")
    if editor
      if @get("isEditing")
        editor.enable()
      else
        editor.disable()
  ).observes('isEditing')

  disableEditingInitially: (->
    # HACK: unfortunately we have to wait for the UI
    # to be able to use the adapter to manipulate the VE model
    @get('controller').updateFigures()

    @set('controller.lockedBy', null)
  ).on('didInsertElement')

  subNavVisibleDidChange: (->
    if @get 'subNavVisible'
      $('.editor-toolbar').css 'top', '103px'
      $('html').addClass 'control-bar-sub-nav-active'
    else
      $('.editor-toolbar').css 'top', '60px'
      $('html').removeClass 'control-bar-sub-nav-active'
  ).observes('subNavVisible')

  teardownControlBarSubNav: (->
    $('html').removeClass 'control-bar-sub-nav-active'
  ).on('willDestroyElement')

  destroyEditor: ( ->
    Ember.$(document).off 'keyup.autoSave'
  ).on('willDestroyElement')

  saveTitleChanges: (->
    @timeoutSave()
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
    documentBody = @get('editor').toHtml()
    @get('controller').send('updateDocumentBody', documentBody)

  actions:
    submit: ->
      @saveEditorChanges()
      @get('controller').send('confirmSubmitPaper')

    showSubNav: (sectionName)->
      if @get('subNavVisible') and @get("#{sectionName}Visible")
        @send 'hideSubNav'
      else
        @set 'subNavVisible', true
        @send "show#{sectionName.capitalize()}"

    hideSubNav: ->
      @setProperties
        subNavVisible: false
        contributorsVisible: false
        downloadsVisible: false

    showContributors: ->
      @set 'contributorsVisible', true
      @set 'downloadsVisible', false

    showDownloads: ->
      @set 'contributorsVisible', false
      @set 'downloadsVisible', true

`export default PaperEditView`
