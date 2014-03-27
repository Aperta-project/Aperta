ETahi.ControllerParticipants = Ember.Mixin.create
  allUsers: (->
    @store.all('user') #simply getting all users for now
  ).property()


  availableParticipants: Ember.computed.setDiff('allUsers', 'participants')

  participants: Ember.computed.alias 'model.participants'

  selectedUser: null

  selectedUserDidChange: (->
    Ember.run.once(this, @addParticipant)
  ).observes('selectedUser')

  addParticipant:(->
    selectedUser = @get('selectedUser')
    if selectedUser
      @get('participants').pushObject(selectedUser)
  )
