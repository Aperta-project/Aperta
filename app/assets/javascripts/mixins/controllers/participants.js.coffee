ETahi.ControllerParticipants = Ember.Mixin.create
  needs: ['application']
  currentUser: Ember.computed.alias('controllers.application.currentUser')
  allUsers: (->
    @store.all('user') #simply getting all users for now
  ).property()

  participants: Em.computed.alias('model.participants')
  actions:
    addParticipant: (newParticipant) ->
      if newParticipant
        @get('participants').pushObject(newParticipant)
    removeParticipant: (participant) ->
      @get('participants').removeObject(participant)
      @send('saveModel')
    saveNewParticipant: (newParticipant) ->
      unless @get('participants').contains newParticipant
        @get('participants').pushObject(newParticipant)
        @send('saveModel')
