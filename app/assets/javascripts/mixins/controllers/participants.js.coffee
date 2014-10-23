ETahi.ControllerParticipants = Ember.Mixin.create
  needs: ['application']
  currentUser: Ember.computed.alias('controllers.application.currentUser')

  # this will get nuked eventually
  participations: []

  participants: (->
    @get('participations').mapBy('participant')
  ).property('participations.@each.participant')

  createParticipant: (newParticipant) ->
    if newParticipant and !@get('participants').contains newParticipant
      @store.createRecord('participation', participant: newParticipant, task: @get('model'))

  findParticipation: (participantId) ->
    @get('participations').findBy("participant.id", participantId)

  actions:
    saveNewParticipant: (newParticipantId) ->
      @store.find('user', newParticipantId).then (user)=>
        if part = @createParticipant(user)
          part.save() unless @get('model.isNew')
    removeParticipant: (participantId) ->
      if part = @findParticipation("" + participantId)
        part.deleteRecord()
        part.save() unless @get('model.isNew')
