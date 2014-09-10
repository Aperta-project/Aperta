ETahi.ProfileAvatarView = Ember.View.extend ETahi.SpinnerMixin,
  templateName: 'user/profile_avatar'

  toggleSpinner: (->
    @createSpinner('controller.isUploading', '.profile-avatar-spinner', color: '#fff')
  ).observes('controller.isUploading').on('didInsertElement')
