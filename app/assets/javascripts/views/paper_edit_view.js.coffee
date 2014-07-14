ETahi.PaperEditView = Ember.View.extend
  visualEditor: null

  locked: Ember.computed.alias 'controller.locked'
  isEditing: Ember.computed.alias 'controller.isEditing'

  logoUrl: (->
    logoUrl = @get('controller.model.journal.logoUrl')
    if /no-journal-image/.test logoUrl
      false
    else
      logoUrl
  ).property()

  documentNode: ->
    surf = @get('visualEditor').surface
    ve.dm.converter.getDomFromModel(surf.getModel().getDocument())

  setBackgroundColor:(->
    $('html').addClass('matte')
  ).on('didInsertElement')

  bindPlaceholderEvent: ->
    $('.editable').on "keyup", "div[contenteditable]", (e) =>
      content = $(ve.dm.converter.getDomFromModel(@get('visualEditor').surface.getModel().getDocument())).text()
      @set('controller.showPlaceholder', Ember.isBlank content)

  applyManuscriptCss:(->
    $('#paper-body').attr('style', @get('controller.model.journal.manuscriptCss'))
  ).on('didInsertElement')

  resetBackgroundColor:(->
    $('html').removeClass('matte')
  ).on('willDestroyElement')

  setupScrollFixing: (->
    $('.control-bar').scrollToFixed()

    $('#tahi-container > main > aside > div').scrollToFixed
      marginTop: $('.control-bar').outerHeight()
      unfixed: ->
        $(this).css('top', '0px')
  ).on('didInsertElement')

  updateToolbarLockedState: ( ->
    $('.oo-ui-toolbar-bar').toggleClass('locked', !@get('isEditing'))
  ).observes('isEditing')

  setupStickyToolbar: ->
    marginTop = $('.control-bar').outerHeight()
    $('.oo-ui-toolbar').scrollToFixed
      marginTop: marginTop
      unfixed: ->
        $(this).addClass('not-fixed')
      preFixed: ->
        $(this).removeClass('not-fixed')
        $(this).css('marginTop', '0')
    $('.edit-paper').scrollToFixed
      marginTop: marginTop + 5
      zIndex: 1010
      preFixed: ->
        $(this).css('marginTop', '5')

  setupVisualEditor: (->
    ve.init.platform.setModulesUrl('/visual-editor/modules')
    @updateVisualEditor()
    @addObserver 'controller.body', =>
      @updateVisualEditor()

    @bindPlaceholderEvent()
    @setupAutosave()
  ).on('didInsertElement')

  updateVisualEditor: ->
    container = $('<div>')

    $('#paper-body').html('').append(container)

    ve.debug = false # it's true by default, which adds a gray background
                     # on initialize and update
    target = new ve.init.sa.Target(
      container,
      ve.createDocumentFromHtml(@get('controller.body') || '')
    )

    self = @
    target.on('surfaceReady', ->
      target.toolbar.disableFloatable()
      self.setupStickyToolbar()
      self.updateToolbarLockedState()
    )
    @set('visualEditor', target)

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
    documentNode = @documentNode()
    newBody = $(documentNode).find('body').html()
    @get('controller').send('updateDocumentBody', newBody)

  actions:
    submit: ->
      @saveVisualEditorChanges()
      @get('controller').send('confirmSubmitPaper')
