ETahi.AdminJournalUserController = Ember.ObjectController.extend
  needs: ['journalIndex']
  resetPasswordSuccess: false
  resetPasswordFailure: false
  rolesList: Em.computed 'controllers.journalIndex.model.roles.@each', 'roles.@each', ->
    journalRoles = @get 'controllers.journalIndex.model.roles'
    journalRoles.reject (role) => @get('roles').isAny('name', role.get('name')) or role.get('isDirty')
                .map (role) ->
                  value: role.get 'name'
                  roleObj: role

  roleQuery: ''
  createRoleObject: (userRole) ->
    Em.Object.create
      name: userRole.get 'role.name'
      userRoleId: userRole.get 'id'

  roles: Em.computed -> @get('userRoles').map @createRoleObject

  isAddingRole: false

  actions:
    removeRole: (role) ->
      @store.getById 'userRole', role.userRoleId
            .destroyRecord().then =>
              role = @get('roles').findBy 'userRoleId', role.userRoleId
              @get('roles').removeObject role

    addRole: -> @set 'isAddingRole', true

    createRole: (role) ->
      userRole = @store.createRecord 'userRole',
        user: @get 'model'
        role: role

      userRole.save()
              .then (userRole) => @get('roles').pushObject @createRoleObject(userRole)
              .catch (res) =>
                userRole.transitionTo 'created.uncommitted'
                userRole.deleteRecord()
              .finally =>
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
