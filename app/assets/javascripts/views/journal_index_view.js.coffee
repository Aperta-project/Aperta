ETahi.JournalIndexView = Ember.View.extend ETahi.SpinnerMixin,
  toggleSpinner: (->
    @createSpinner('controller.epubCoverUploading', '#epub-cover-spinner', color: '#aaa')
  ).observes('controller.epubCoverUploading').on('didInsertElement')
