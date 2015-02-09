`import Ember from 'ember'`
`import FileUploadMixin from 'tahi/mixins/file-upload'`

UserAvatarComponent = Ember.Component.extend FileUploadMixin,
  avatarUploadUrl: "/users/update_avatar"

  actions:
    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)
      @set 'user.avatarUrl', data.avatar_url

`export default UserAvatarComponent`
