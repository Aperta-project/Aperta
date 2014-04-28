ETahi.PaperNewView = Ember.View.extend
  setBackgroundColor:(->
    $('html').addClass('matte')
  ).on('didInsertElement')

  resetBackgroundColor:(->
    $('html').removeClass('matte')
  ).on('willDestroyElement')

  focusOnTitleField: (->
    @.$('#paper-short-title').focus()
  ).on('didInsertElement')
