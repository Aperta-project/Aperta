ETahi.JournalThumbnailView = Ember.View.extend ETahi.SpinnerMixin,
  _init: (->
    @get('controller.isUploading') # this property needs to be fetched here in order to trigger the
                                   # observer later.
  ).on('didInsertElement')

  toggleSpinner: (->
    @createSpinner('controller.isUploading', '.journal-logo-spinner', '#fff')
  ).observes('controller.isUploading')

  togglePreview: (->
    Ember.run.schedule 'afterRender', =>
      if @get('controller.logoPreview')
        @$('.journal-logo-preview').empty().append(@get('controller.logoPreview'))
      else
        @$('.journal-logo-preview').html('')
  ).observes('controller.logoPreview')
