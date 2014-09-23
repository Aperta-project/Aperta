ETahi.PaperIndexView = Ember.View.extend
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
      dontSetWidth: true
      marginTop: $('.control-bar').outerHeight(true)
      unfixed: ->
        $(this).css('top', '0px')
  ).on('didInsertElement')
