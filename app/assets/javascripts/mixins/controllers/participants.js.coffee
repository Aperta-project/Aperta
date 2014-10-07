ETahi.ControllerParticipants = Ember.Mixin.create
  needs: ['application']
  currentUser: Ember.computed.alias('controllers.application.currentUser')
  allUsers: (->
    @store.all('user') #simply getting all users for now
  ).property()

  participations: Em.computed.alias('model.participations')
  participants: (->
    @get('participations').map (participation) ->
      participation.get('participant')
  ).property('participations.@each.participant')

  createParticipant: (newParticipant) ->
    if newParticipant and !@get('participants').contains newParticipant
      @store.createRecord('participation', participant: newParticipant, task: @get('model'))

  actions:
    addParticipant: (newParticipant) ->
      @createParticipant(newParticipant)

    saveNewParticipation: (newParticipant) ->
      if part = @createParticipant(newParticipant)
        part.save()
