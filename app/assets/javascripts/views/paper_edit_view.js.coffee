ETahi.PaperEditView = Ember.View.extend
  setBackgroundColor:(->
    $('html').addClass('matte')
  ).on('didInsertElement')

  setupVisualEditor: (->
    ve.init.platform.setModulesUrl('/visual-editor/modules')
    html = @get('controller.model.body')
    container = $('<div>')

    $('#paper-body').append(container)

    target = new ve.init.sa.Target(
      container,
      ve.createDocumentFromHtml(html)
    )
  ).on('didInsertElement')

  resetBackgroundColor:(->
    $('html').removeClass('matte')
  ).on('willDestroyElement')
