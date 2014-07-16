ETahi.AdminJournalUserController = Ember.ObjectController.extend
  needs: ['journalIndex']
  resetPasswordSuccess: false
  resetPasswordFailure: false
  rolesList: Em.computed.alias 'controllers.journalIndex.rolesList'
  roles: []
  roleQuery: ''

  isAddingRole: false

  actions:
    removeRole: (role) ->
      i = @get('roles').indexOf role
      @get('roles').removeAt i

    addRole: -> @set 'isAddingRole', true

    createRole: (role) ->
      @get('roles').pushObject role
      @setProperties
        isAddingRole: false
        roleQuery: ''

    saveUser: ->
      @get('model').save().then =>
        @send('closeOverlay')

    rollbackUser: ->
      @get('model').rollback()
      @send('closeOverlay')

    resetPassword: (user) ->
      $.get "/admin/journal_users/#{user.id}/reset"
      .done => @set 'resetPasswordSuccess', true
      .fail => @set 'resetPasswordFailure', true
