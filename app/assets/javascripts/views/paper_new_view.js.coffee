ETahi.PaperNewView = Ember.View.extend
  focusOnTitleField: (->
    @.$('#paper-short-title').focus()
  ).on('didInsertElement')
