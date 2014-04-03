ETahi.PaperEditView = Ember.View.extend
  setBackgroundColor:(->
    $('body').addClass('matte')
  ).on('didInsertElement')

  resetBackgroundColor:(->
    $('body').removeClass('matte')
  ).on('willDestroyElement')
