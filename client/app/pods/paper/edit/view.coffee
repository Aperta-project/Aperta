`import Ember from 'ember'`
`import RedirectsIfEditable from 'tahi/mixins/views/redirects-if-editable'`

PaperEditView = Ember.View.extend RedirectsIfEditable,

  # initialized by component helper {{visual-editor}}
  visualEditor: null

  # initialized by component helper {{visual-editor-toolbar}}
  toolbar: null

  locked: Ember.computed.alias 'controller.locked'
  isEditing: Ember.computed.alias 'controller.isEditing'
  subNavVisible: false
  downloadsVisible: false
  contributorsVisible: false

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
    $('.oo-ui-toolbar-bar').toggleClass('locked', !@get('isEditing'))

    if @get("isEditing")
      @get("visualEditor")?.enable()
    else
      @get("visualEditor")?.disable()
  ).observes('isEditing')

  subNavVisibleDidChange: (->
    if @get 'subNavVisible'
      $('html').addClass 'control-bar-sub-nav-active'
    else
      $('html').removeClass 'control-bar-sub-nav-active'
  ).observes('subNavVisible')

  setupVisualEditor: (->
    @updateVisualEditor()
    @addObserver 'controller.body', =>
      @updateVisualEditor() unless @get('isEditing')

    @setupAutosave()
  ).on('didInsertElement')

  updateVisualEditor: ->
    editorModel = @get('visualEditor.model')
    editorModel.fromHtml(@get('controller.body'))
    @updateEditorLockedState()

  teardownControlBarSubNav: (->
    $('html').removeClass 'control-bar-sub-nav-active'
  ).on('willDestroyElement')

  destroyVisualEditor: ( ->
    Ember.$(document).off 'keyup.autoSave'
  ).on('willDestroyElement')

  saveTitleChanges: (->
    @timeoutSave()
  ).on('willDestroyElement')

  timeoutSave: ->
    return if Ember.testing # TODO: make this injectable via visual editor lifecycle hooks
    @saveVisualEditorChanges()
    @get('controller').send('savePaper')
    Ember.run.cancel(@short)
    Ember.run.cancel(@long)
    @short = null
    @long = null
    @keyCount = 0

  short: null
  long: null
  keyCount: 0

  setupAutosave: ->
    # The timeout times and keyup counter are arbitrary. Feel free to tweak.
    Ember.$(document).on 'keyup.autoSave', '.ve-ui-surface, #paper-title', =>
      # Check for a window timeout so we aren't waiting in testing.
      @short = Ember.run.debounce(@, @timeoutSave, window.shortTimeout || (1000 * 10))
      unless @long
        @long = Ember.run.later(@, @timeoutSave, 1000 * 60)
      @keyCount++
      if @keyCount > 200
        @timeoutSave()

  saveVisualEditorChanges: ->
    documentBody = @get('visualEditor.model').toHtml()
    @get('controller').send('updateDocumentBody', documentBody)

  actions:
    submit: ->
      @saveVisualEditorChanges()
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
