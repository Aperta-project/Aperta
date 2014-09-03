ETahi.JournalThumbnailView = Ember.View.extend
  toggleSpinner: (->
    return unless @$()
    Em.run =>
      if @get('controller.isUploading')
        spinnerContainer = $('<div class="journal-logo-spinner"></div>')
        @$('.journal-logo-upload').append spinnerContainer
        new Spinner(color: "#fff").spin(spinnerContainer.get(0))
      else
        @$('.journal-logo-spinner').remove()
  ).observes('controller.isUploading')

  togglePreview: (->
    Ember.run.schedule 'afterRender', =>
      if @get('controller.logoPreview')
        @$('.journal-logo-preview').empty().append(@get('controller.logoPreview'))
      else
        @$('.journal-logo-preview').html('')
  ).observes('controller.logoPreview')
