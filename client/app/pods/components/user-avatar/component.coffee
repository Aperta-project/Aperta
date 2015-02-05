`import Ember from 'ember'`
`import FileUploadMixin from 'tahi/mixins/file-upload'`
`import ValidationErrorsMixin from 'tahi/mixins/validation-errors'`
`import Utils from 'tahi/services/utils'`

UserAvatarComponent = Ember.Component.extend FileUploadMixin, ValidationErrorsMixin,
  errorText: ""

  avatarUploadUrl: ( ->
    "/users/#{@get('model.id')}/update_avatar"
  ).property('id')

  actions:
    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)
      @set 'model.avatarUrl', data.avatar_url

`export default UserAvatarComponent`
