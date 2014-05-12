ETahi.PaperEditView = Ember.View.extend
  visualEditor: null

  setBackgroundColor:(->
    $('html').addClass('matte')
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
