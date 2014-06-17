ETahi.JournalThumbnailView = Ember.View.extend
  isHovering: false
  mouseEnter: -> @set('isHovering', true)
  mouseLeave: -> @set('isHovering', false)

  toggleSpinner: (->
    if @get('controller.logoUploading')
      @spinnerDiv = @$('.journal-logo-spinner')[0]
      @spinner ||= new Spinner(color: "#fff").spin(@spinnerDiv)
      $(@spinnerDiv).show()
    else
      $(@spinnerDiv).hide()
  ).observes('controller.logoUploading')
