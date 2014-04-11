ETahi.PaperEditView = Ember.View.extend
  visualEditor: null,

  setBackgroundColor:(->
    $('html').addClass('matte')
  ).on('didInsertElement')

  resetBackgroundColor:(->
    $('html').removeClass('matte')
  ).on('willDestroyElement')

  setupScrollFixing: (->
    $('.control-bar').scrollToFixed()

    $('#tahi-container > main > aside > div').scrollToFixed
      marginTop: $('.control-bar').outerHeight(true)
      unfixed: ->
        $(this).css('top', '0px')

    Em.run.later (->
      $('.oo-ui-toolbar').scrollToFixed
        marginTop: $('.control-bar').outerHeight(true)
        unfixed: ->
          $(this).addClass('not-fixed')
          $(this).css('marginTop', '-86px')
        preFixed: ->
          $(this).removeClass('not-fixed')
          $(this).css('marginTop', '0')

    ), 250
  ).on('didInsertElement')

  setupVisualEditor: (->
    ve.init.platform.setModulesUrl('/visual-editor/modules')
    container = $('<div>')

    $('#paper-body').append(container)

    target = new ve.init.sa.Target(
      container,
      ve.createDocumentFromHtml(@get('controller.model.body') || '')
    )

    # :( VE seems to need time to initialize:
    Em.run.later (->
      target.toolbar.disableFloatable()
    ), 250

    @set('visualEditor', target)
  ).on('didInsertElement')

  saveVisualEditorChanges: ->
    documentNode = ve.dm.converter.getDomFromModel(@get('visualEditor').surface.getModel().getDocument())
    @set('controller.model.body', $(documentNode).find('body').html())

  actions:
    save: ->
      @saveVisualEditorChanges()
      @get('controller').send('savePaper')

    submit: ->
      @saveVisualEditorChanges()
      @get('controller').send('confirmSubmitPaper')
