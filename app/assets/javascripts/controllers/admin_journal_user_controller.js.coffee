ETahi.AdminJournalUserController = Ember.ObjectController.extend
  needs: ['journalIndex']

  # TODO: This should be in a new controller
  overlayClass: 'overlay--fullscreen user-detail-overlay'
  resetPasswordSuccess: false
  resetPasswordFailure: false

  journalRoles: Em.computed.alias 'controllers.journalIndex.model.roles'
  userJournalRoles: Em.computed.mapBy('model.userRoles', 'role')

  selectableJournalRoles: (->
    @get('journalRoles').map (jr) ->
      id: jr.get('id')
      text: jr.get('name')
  ).property('journalRoles')

  selectableUserJournalRoles: (->
    @get('userJournalRoles').map (jr) ->
      id: jr.get('id')
      text: jr.get('name')
  ).property('userJournalRoles')

  actions:
    removeRole: (roleObj) ->
      @get('model.userRoles').findBy('role.id', roleObj.id).destroyRecord()

    assignRole: (roleObj) ->
      userRole = @store.createRecord 'userRole',
        user: @get 'model'
        role: @store.getById('role', roleObj.id)
      userRole.save()


    # TODO: This should be in a new controller
    #
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
