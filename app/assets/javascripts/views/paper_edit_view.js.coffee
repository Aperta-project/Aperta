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
    Ember.$(document).on 'keypress', '.ve-ui-surface, #paper-title', (e) =>
      @get('controller.model').set('saved', false)
      # TODO: use e.which to ingore certain characters (like cmd, ctrl)
      @short = Ember.run.debounce(@, @timeoutSave, 1000 * 10)
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
