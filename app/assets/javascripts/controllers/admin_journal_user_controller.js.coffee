ETahi.AdminJournalUserController = Ember.ObjectController.extend
  resetPasswordSuccess: (->
    false
  ).property()

  resetPasswordFailure: (->
    false
  ).property()

  modalId: (->
    "#{@get('id')}-#{@get('username')}"
  ).property('username', 'id')

  actions:
    saveUser: ->
      @get('model').save()

    rollbackUser: ->
      @get('model').rollback()

    resetPassword: (user) ->
      $.get("/admin/journal_users/#{user.id}/reset").done(=>
        @set 'resetPasswordSuccess', true
      ).fail =>
        @set 'resetPasswordFailure', true
