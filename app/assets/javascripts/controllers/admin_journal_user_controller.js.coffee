ETahi.AdminJournalUserController = Ember.ObjectController.extend
  resetPasswordSuccess: false

  resetPasswordFailure: false

  actions:
    saveUser: ->
      @get('model').save().then =>
        @send('closeOverlay')

    rollbackUser: ->
      @get('model').rollback()
      @send('closeOverlay')

    resetPassword: (user) ->
      $.get("/admin/journal_users/#{user.id}/reset").done(=>
        @set 'resetPasswordSuccess', true
      ).fail =>
        @set 'resetPasswordFailure', true
