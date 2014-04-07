ETahi.ControllerParticipants = Ember.Mixin.create
  needs: ['application']
  allUsers: (->
    @store.all('user') #simply getting all users for now
  ).property()


  currentUser: Ember.computed.alias 'controllers.application.currentUser'
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
