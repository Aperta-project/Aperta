ETahi.PaperEditView = Ember.View.extend
  visualEditor: Ember.computed.alias('controller.visualEditor')

  locked: Ember.computed.alias 'controller.locked'
  isEditing: Ember.computed.alias 'controller.isEditing'

  setBackgroundColor: (->
    $('.main-content').addClass 'matte'
  ).on('didInsertElement')

  resetBackgroundColor: (->
    $('.main-content').removeClass 'matte'
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

  setupScrollFixing: (->
    aside       = $('aside')
    article     = $('article')
    mainContent = $('.main-content')
    veToolbar   = $('.oo-ui-toolbar')
    controlBar  = $('.control-bar')
    editPaper   = $('.edit-paper')
    controlBarHeight = controlBar.outerHeight()
    toolbarUnderside = $('.ve-toolbar-underside')

    $(window).off('resize.paper').on('resize.paper', ->
      articleWidth          = article.width()
      controlBarHeight      = controlBar.outerHeight()
      articleOffsetLeft     = article.offset().left
      mainContentOffsetLeft = mainContent.offset().left

      aside.css 'left', (articleWidth + articleOffsetLeft - mainContentOffsetLeft)
      toolbarUnderside.css 'left', (articleOffsetLeft - mainContentOffsetLeft)
      editPaper.css 'left', (articleOffsetLeft - mainContentOffsetLeft)
      veToolbar.css 'left', (articleOffsetLeft - mainContentOffsetLeft)
    )

    toolbarUnderside.css
      top: controlBarHeight

    aside.css
      position: 'fixed'
      top: controlBarHeight

    veToolbar.css
      top: controlBarHeight

    editPaper.css
      top: controlBarHeight + 5

    $(window).trigger 'resize.paper'
  ).on('didInsertElement')

  teardownScrollFixing: (->
    $(window).off 'resize.paper'
  ).on('willDestroyElement')

  updateEditorLockedState: ( ->
    $('.oo-ui-toolbar-bar').toggleClass('locked', !@get('isEditing'))

    if @get("isEditing")
      @get("visualEditor").enable()
    else
      @get("visualEditor").disable()
  ).observes('isEditing')

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
      @setupScrollFixing()
      @updateEditorLockedState()

  destroyVisualEditor: ( ->
    Ember.$(document).off 'keyup.autoSave'
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
