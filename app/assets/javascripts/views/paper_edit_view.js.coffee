ETahi.PaperEditView = Ember.View.extend
  setBackgroundColor:(->
    $('html').addClass('matte')
  ).on('didInsertElement')

  resetBackgroundColor:(->
    $('html').removeClass('matte')
  ).on('willDestroyElement')
