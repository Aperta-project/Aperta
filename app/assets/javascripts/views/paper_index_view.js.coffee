ETahi.PaperIndexView = Ember.View.extend
  applyManuscriptCss:(->
    $('#paper-body').attr('style', @get('controller.model.journal.manuscriptCss'))
  ).on('didInsertElement')

  setupScrollFixing: (->
    $('.control-bar').scrollToFixed()
    $('#tahi-container > main > aside > div').scrollToFixed
      dontSetWidth: true
      marginTop: $('.control-bar').outerHeight(true)
      unfixed: ->
        $(this).css('top', '0px')
  ).on('didInsertElement')
