ETahi.JournalThumbnailView = Ember.View.extend
  toggleSpinner: (->
    if @get('controller.logoUploading')
      @spinnerDiv = @$('.journal-logo-spinner')[0]
      @spinner ||= new Spinner(color: "#fff").spin(@spinnerDiv)
      $(@spinnerDiv).show()
    else
      $(@spinnerDiv).hide()
  ).observes('controller.logoUploading')
