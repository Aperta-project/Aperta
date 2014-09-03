ETahi.ProfileAvatarView = Ember.View.extend
  templateName: 'user/profile_avatar'

  toggleSpinner: (->
    return unless @$()
    Em.run =>
      if @get('controller.isUploading')
        spinnerContainer = $('<div class="profile-avatar-spinner"></div>')
        @$('#profile-avatar').append spinnerContainer
        new Spinner(color: "#fff").spin(spinnerContainer.get(0))
      else
        @$('.profile-avatar-spinner').remove()
  ).observes('controller.isUploading')
