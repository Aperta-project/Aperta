ETahi.ControllerParticipants = Ember.Mixin.create
  needs: ['application']
  currentUser: Ember.computed.alias('controllers.application.currentUser')
  allUsers: (->
    paperId = @get('paper.id') || @get('litePaper.id')
    DS.PromiseObject.create
      promise: $.getJSON("/filtered_users/collaborators/#{paperId}")
  ).property()

  participants: Em.computed.alias('model.participants')
  actions:
    addParticipant: (newParticipant) ->
      if newParticipant
        @get('participants').pushObject(newParticipant)
    removeParticipant: (participant) ->
      @get('participants').removeObject(participant)
      @send('saveModel')
    saveNewParticipant: (newParticipantId) ->
      newParticipant = this.store.find 'user', newParticipantId
      newParticipant.then (user)=>
        unless @get('participants').contains user
          @get('participants').pushObject(user)
          @send('saveModel') unless @get('model.isNew')
