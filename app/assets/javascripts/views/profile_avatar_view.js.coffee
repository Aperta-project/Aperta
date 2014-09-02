ETahi.ProfileAvatarView = Ember.View.extend
  templateName: 'user/profile_avatar'

  toggleSpinner: (->
    Em.run =>
      if @get('controller.isUploading')
        @spinnerDiv = @$('#profile-avatar-spinner')[0]
        @spinner ||= new Spinner(color: "#fff").spin(@spinnerDiv)
        $(@spinnerDiv).show()
      else
        $(@spinnerDiv).hide()
  ).observes('controller.isUploading')
