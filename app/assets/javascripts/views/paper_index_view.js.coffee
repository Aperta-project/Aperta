ETahi.PaperIndexView = Ember.View.extend
  applyManuscriptCss:(->
    $('#paper-body').attr('style', @get('controller.model.journal.manuscriptCss'))
  ).on('didInsertElement')

  setBackgroundColor: (->
    $('.main-content').addClass 'matte'
  ).on('didInsertElement')

  resetBackgroundColor: (->
    $('.main-content').removeClass 'matte'
  ).on('willDestroyElement')

  setupScrollFixing: (->
    aside       = $('aside')
    article     = $('article')
    mainContent = $('.main-content')

    $(window).off('resize.paper').on('resize.paper', ->
      aside.css 'left', (article.width() + article.offset().left - mainContent.offset().left)
    )

    aside.css
      position: 'fixed'
      top: $('.control-bar').outerHeight() + 15

    $(window).trigger 'resize.paper'
  ).on('didInsertElement')

  teardownScrollFixing: (->
    $(window).off 'resize.paper'
  ).on('willDestroyElement')
