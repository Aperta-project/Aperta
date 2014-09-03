ETahi.ControllerParticipants = Ember.Mixin.create
  allUsers: (->
    @store.all('user') #simply getting all users for now
  ).property()

  participants: Em.computed.alias('model.participants')

  actions:
    addParticipant: (newParticipant) ->
      if newParticipant
        @get('participants').pushObject(newParticipant)
    saveNewParticipant: (newParticipant) ->
      unless @get('participants').contains newParticipant
        @get('participants').pushObject(newParticipant)
        @send('saveModel')
