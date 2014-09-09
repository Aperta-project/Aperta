ETahi.ProfileAvatarView = Ember.View.extend ETahi.SpinnerMixin,
  templateName: 'user/profile_avatar'

  _init: (->
    @get('controller.isUploading') # this property needs to be fetched here in order to trigger the
                                   # observer later.
  ).on('didInsertElement')

  toggleSpinner: (->
    @createSpinner('controller.isUploading', '.profile-avatar-spinner', '#fff')
  ).observes('controller.isUploading')
