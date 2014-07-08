ETahi.PaperEditView = Ember.View.extend
  visualEditor: null

  locked: Ember.computed.alias 'controller.locked'

  logoUrl: (->
    logoUrl = @get('controller.model.journal.logoUrl')
    if /no-journal-image/.test logoUrl
      false
    else
      logoUrl
  ).property()

  setBackgroundColor:(->
    $('html').addClass('matte')
  ).on('didInsertElement')

  placeholderBlur: ->
    $('.editable').on "blur", "div[contenteditable]", (e) =>
      content = $(ve.dm.converter.getDomFromModel(@get('visualEditor').surface.getModel().getDocument())).text()
      if Ember.isBlank content
        @set('controller.showPlaceholder', true)

  placeholderFocus: ->
    $('.editable').on "focus", "div[contenteditable]", (e) =>
      @set('controller.showPlaceholder', false)

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
    $('.oo-ui-toolbar').toggleClass('locked', @get('locked'))
  ).observes('locked').on('init')

  setupStickyToolbar: ->
    $('.oo-ui-toolbar').scrollToFixed
      marginTop: $('.control-bar').outerHeight()
      unfixed: ->
        $(this).addClass('not-fixed')
      preFixed: ->
        $(this).removeClass('not-fixed')
        $(this).css('marginTop', '0')

  setupVisualEditor: (->
    ve.init.platform.setModulesUrl('/visual-editor/modules')
    @updateVisualEditor()
    @addObserver 'controller.body', =>
      @updateVisualEditor()

    @placeholderFocus()
    @placeholderBlur()
  ).on('didInsertElement')

  updateVisualEditor: ->
    container = $('<div>')

    $('#paper-body').html('').append(container)
    target = new ve.init.sa.Target(
      container,
      ve.createDocumentFromHtml(@get('controller.body') || '')
    )

    self = @
    target.on('surfaceReady', ->
      target.toolbar.disableFloatable()
      self.setupStickyToolbar()
    )

    @set('visualEditor', target)
    @setupAutosave()

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
    Ember.$(document).on 'keyup', '.ve-ui-surface, #paper-title', =>
      @get('controller').set('saveState', "Saving...")
      # Check for a window timeout so we aren't waiting in testing.
      @short = Ember.run.debounce(@, @timeoutSave, window.shortTimeout || (1000 * 10))
      unless @long
        @long = Ember.run.later(@, @timeoutSave, 1000 * 60)
      @keyCount++
      if @keyCount > 200
        @timeoutSave()

  saveVisualEditorChanges: ->
    documentNode = ve.dm.converter.getDomFromModel(@get('visualEditor').surface.getModel().getDocument())
    @set('controller.body', $(documentNode).find('body').html())

  actions:
    save: ->
      @saveVisualEditorChanges()
      @get('controller').send('savePaper')

    submit: ->
      @saveVisualEditorChanges()
      @get('controller').send('confirmSubmitPaper')
