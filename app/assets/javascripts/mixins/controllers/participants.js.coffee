ETahi.ControllerParticipants = Ember.Mixin.create
  needs: ['application']
  currentUser: Ember.computed.alias('controllers.application.currentUser')
  allUsers: (->
    @store.all('user') #simply getting all users for now
  ).property()

  participations: Em.computed.alias('model.participations')
  participants: (->
    @get('participations').map (participation) ->
      participation.get('user')
  ).property('participations.@each.user')

  actions:
    addParticipant: (newParticipant) ->
      if newParticipant
        @get('participants').pushObject(newParticipant)
    saveNewParticipation: (newParticipant) ->
      unless @get('participants').contains newParticipant
        part = @store.createRecord('participation', user: newParticipant, task: @get('model'))
        part.save()
        # @get('participants').pushObject(newParticipant)
        # @send('saveModel')
