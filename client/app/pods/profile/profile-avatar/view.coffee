`import Ember from 'ember'`
`import SpinnerMixin from 'tahi/mixins/views/spinner'`

ProfileAvatarView = Ember.View.extend SpinnerMixin,
  # templateName: 'user/profile_avatar'

  toggleSpinner: (->
    @createSpinner('controller.isUploading', '.profile-avatar-spinner', color: '#fff')
  ).observes('controller.isUploading').on('didInsertElement')

`export default ProfileAvatarView`
