ETahi.PaperEditView = Ember.View.extend
  visualEditor: null,

  setBackgroundColor:(->
    $('html').addClass('matte')
  ).on('didInsertElement')

  setupVisualEditor: (->
    ve.init.platform.setModulesUrl('/visual-editor/modules')
    container = $('<div>')

    $('#paper-body').append(container)

    target = new ve.init.sa.Target(
      container,
      ve.createDocumentFromHtml(@get('controller.model.body'))
    )

    @set('visualEditor', target)
  ).on('didInsertElement')

  resetBackgroundColor:(->
    $('html').removeClass('matte')
  ).on('willDestroyElement')

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
