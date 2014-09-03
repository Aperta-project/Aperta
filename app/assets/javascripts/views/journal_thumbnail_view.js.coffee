ETahi.JournalThumbnailView = Ember.View.extend
  toggleSpinner: (->
    return unless @$()
    spinnerContainer = $('<div class="journal-logo-spinner"></div>')

    if @get('controller.isUploading')
      @$('.journal-logo-upload').append spinnerContainer
      new Spinner(color: "#fff").spin(spinnerContainer.get(0))
    else
      spinnerContainer.remove()
  ).observes('controller.isUploading')

  togglePreview: (->
    Ember.run.schedule 'afterRender', =>
      if @get('controller.logoPreview')
        @$('.journal-logo-preview').empty().append(@get('controller.logoPreview'))
      else
        @$('.journal-logo-preview').html('')
  ).observes('controller.logoPreview')
