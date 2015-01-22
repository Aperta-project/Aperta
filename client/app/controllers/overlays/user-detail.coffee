`import Ember from 'ember'`
`import ValidationErrorsMixin from 'tahi/mixins/validation-errors'`

UserDetailOverlayController = Ember.ObjectController.extend ValidationErrorsMixin,
  overlayClass: 'overlay--fullscreen user-detail-overlay'
  resetPasswordSuccess: false
  resetPasswordFailure: false

  actions:
    saveUser: ->
      @get('model').save()
                   .then =>
                     @clearValidationErrors()
                     @send('closeOverlay')
                   .catch (response) =>
                     @displayValidationErrorsFromResponse response

    rollbackUser: ->
      @get('model').rollback()
      @clearValidationErrors()
      @send('closeOverlay')

    resetPassword: (user) ->
      $.get "/admin/journal_users/#{user.get('id')}/reset"
      .done => @set 'resetPasswordSuccess', true
      .fail => @set 'resetPasswordFailure', true

`export default UserDetailOverlayController`
