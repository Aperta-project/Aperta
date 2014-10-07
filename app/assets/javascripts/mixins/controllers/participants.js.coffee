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
    saveNewParticipant: (newParticipantId) ->
      @store.find('user', newParticipantId).then (user)=>
        @get('participants').addObject(user)
        @send('saveModel') unless @get('model.isNew')
