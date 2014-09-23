ETahi.ControllerParticipants = Ember.Mixin.create
  needs: ['application']
  currentUser: Ember.computed.alias('controllers.application.currentUser')
  allUsers: (->
    DS.PromiseObject.create
      promise: $.getJSON("/tasks/#{@get('model.id')}/collaborators")
  ).property()

  participants: Em.computed.alias('model.participants')

  actions:
    addParticipant: (newParticipant) ->
      if newParticipant
        @get('participants').pushObject(newParticipant)
    saveNewParticipant: (newParticipantId) ->
      newParticipant = this.store.find 'user', newParticipantId
      newParticipant.then (user)=>
        unless @get('participants').contains user
          @get('participants').pushObject(user)
          @send('saveModel')
