ETahi.JournalThumbnailView = Ember.View.extend
  toggleSpinner: (->
    if @get('controller.logoUploading')
      @spinnerDiv = @$('.journal-logo-spinner')[0]
      @spinner ||= new Spinner(color: "#fff").spin(@spinnerDiv)
      $(@spinnerDiv).show()
    else
      $(@spinnerDiv).hide()
  ).observes('controller.logoUploading')

  togglePreview: (->
    Ember.run.schedule 'afterRender', =>
      if @get('controller.logoPreview')
        @$('.journal-logo-preview').append(@get('controller.logoPreview'))
      else
        @$('.journal-logo-preview').html('')
  ).observes('controller.logoPreview')
