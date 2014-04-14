ETahi.PaperIndexView = Ember.View.extend
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
  ).on('didInsertElement')
