ETahi.PaperEditView = Ember.View.extend ETahi.RedirectsIfEditable,
  visualEditor: Ember.computed.alias('controller.visualEditor')

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

  bindPlaceholderEvent: ->
    $('.editable').on "keyup", "div[contenteditable]", (e) =>

      # if we're currently showing placeholder we want it to go away
      # when the user starts typing, without delay
      if @get('controller.showPlaceholder')
        @updatePlaceholder()
      else
        Ember.run.debounce(@, @updatePlaceholder, 1000)

  updatePlaceholder: ->
    @set('controller.showPlaceholder', @get('visualEditor.isEmpty'))

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

    @bindPlaceholderEvent()
    @setupAutosave()
  ).on('didInsertElement')

  updateVisualEditor: ->
    visualEditor = @get('visualEditor')
    visualEditor.update($("#paper-body"), @get('controller.body'))
    visualEditor.get('target').on 'surfaceReady', =>
      @updateEditorLockedState()

  teardownControlBarSubNav: (->
    $('html').removeClass 'control-bar-sub-nav-active'
  ).on('willDestroyElement')

  destroyVisualEditor: ( ->
    Ember.$(document).off 'keyup.autoSave'
  ).on('willDestroyElement')

  saveTitleChanges: (->
    @timeoutSave();
  ).on('willDestroyElement')

  timeoutSave: ->
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
    @get('controller').send('updateDocumentBody', @get('visualEditor.bodyHtml'))

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
