ETahi.JournalThumbnailView = Ember.View.extend ETahi.SpinnerMixin,
  toggleSpinner: (->
    @createSpinner('controller.isUploading', '.journal-logo-spinner', '#fff')
  ).observes('controller.isUploading').on('didInsertElement')

  togglePreview: (->
    Ember.run.schedule 'afterRender', =>
      if @get('controller.logoPreview')
        @$('.journal-logo-preview').empty().append(@get('controller.logoPreview'))
      else
        @$('.journal-logo-preview').html('')
  ).observes('controller.logoPreview')
