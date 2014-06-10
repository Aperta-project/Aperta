ETahi.JournalIndexView = Ember.View.extend
  toggleSpinner: (->
    if @get('controller.epubCoverUploading')
      @spinnerDiv = @$('#epub-cover-spinner')[0]
      @spinner ||= new Spinner(color: "#aaa").spin(@spinnerDiv)
      $(@spinnerDiv).show()
    else
      $(@spinnerDiv).hide()
  ).observes('controller.epubCoverUploading')
