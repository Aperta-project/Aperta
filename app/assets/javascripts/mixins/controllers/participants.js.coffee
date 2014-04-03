ETahi.ControllerParticipants = Ember.Mixin.create
  allUsers: (->
    @store.all('user') #simply getting all users for now
  ).property()


  availableParticipants: Ember.computed.setDiff('allUsers', 'participants')

  participants: Ember.computed.alias 'model.participants'

  actions:
    addParticipant: (newParticipant) ->
      if newParticipant
        @get('participants').pushObject(newParticipant)
    saveNewParticipant: (newParticipant) ->
      if newParticipant
        @get('participants').pushObject(newParticipant)
        @send('saveModel')
