ETahi.AdminJournalUserController = Ember.ObjectController.extend
  needs: ['journalIndex']
  resetPasswordSuccess: false
  resetPasswordFailure: false
  rolesList: Em.computed.alias 'controllers.journalIndex.rolesList'
  roleQuery: ''
  roles: Em.computed ->
    @get('userRoles').map (userRole) ->
      Em.Object.create
        id: userRole.get 'role.id'
        name: userRole.get 'role.name'
        userRoleId: userRole.get 'id'

  isAddingRole: false

  actions:
    removeRole: (role) ->
      @store.getById 'userRole', role.userRoleId
      .destroyRecord()

    addRole: -> @set 'isAddingRole', true

    createRole: (role) ->
      @store.createRecord 'userRole',
        user: @get 'model'
        role: role
      .save().finally =>
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
