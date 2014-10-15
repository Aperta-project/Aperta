ETahi.ControllerParticipants = Ember.Mixin.create
  needs: ['application']
  currentUser: Ember.computed.alias('controllers.application.currentUser')
  allUsers: (->
    paperId = @get('paper.id') || @get('litePaper.id')
    DS.PromiseObject.create
      promise: $.getJSON("/filtered_users/collaborators/#{paperId}")
  ).property()

  # this will get nuked eventually
  participations: []

  participants: (->
    @get('participations').mapBy('participant')
  ).property('participations.@each.participant')

  createParticipant: (newParticipant) ->
    if newParticipant and !@get('participants').contains newParticipant
      @store.createRecord('participation', participant: newParticipant, task: @get('model'))

  findParticipation: (participant) ->
    if participant
      @get('participations').findBy("participant", participant)

  actions:
    saveNewParticipant: (newParticipantId) ->
      @store.find('user', newParticipantId).then (user)=>
        if part = @createParticipant(user)
          part.save() unless @get('model.isNew')
    removeParticipant: (participant) ->
      if part = @findParticipation(participant)
        part.deleteRecord()
        part.save() unless @get('model.isNew')
