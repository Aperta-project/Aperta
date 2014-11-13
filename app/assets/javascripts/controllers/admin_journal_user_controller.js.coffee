ETahi.AdminJournalUserController = Ember.ObjectController.extend
  needs: ['journalIndex']
  overlayClass: 'overlay--fullscreen user-detail-overlay'
  resetPasswordSuccess: false
  resetPasswordFailure: false
  journalRoles: Em.computed.alias 'controllers.journalIndex.model.roles'
  rolesList: Em.computed 'controllers.journalIndex.model.roles.@each', 'roles.@each', ->
    @get 'journalRoles'
    .reject (role) => @get('roles').isAny('name', role.get('name')) or role.get('isDirty')

  roleQuery: ''
  createRoleObject: (userRole) ->
    Em.Object.create
      name: userRole.get 'role.name'
      userRoleId: userRole.get 'id'

  roles: Em.computed 'userRoles.@each.id', -> @get('userRoles').map @createRoleObject

  isAddingRole: false

  actions:
    removeRole: (role) ->
      @store.getById 'userRole', role.userRoleId
            .destroyRecord().then =>
              role = @get('roles').findBy 'userRoleId', role.userRoleId
              @get('roles').removeObject role

    addRoleAssignment: -> @set 'isAddingRole', true

    assignRole: (params) ->
      userRole = @store.createRecord 'userRole',
        user: @get 'model'
        role: params.object

      userRole.save()
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
      $.get "/admin/journal_users/#{user.get('id')}/reset"
      .done => @set 'resetPasswordSuccess', true
      .fail => @set 'resetPasswordFailure', true
