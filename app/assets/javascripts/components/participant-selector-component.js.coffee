ETahi.ParticipantSelectorComponent = Ember.Component.extend
  everyone: []
  currentParticipants: []

  availableParticipants: (->
    return [] if Em.isEmpty @get('everyone.content')

    currentParticipantIds = @get('currentParticipants').mapProperty('id')
    (@get('everyone.content').reject (user) ->
      currentParticipantIds.contains(user.id)).map (user) ->
        Ember.Object.create user
  ).property('everyone.content.[]', 'currentParticipants.@each')

  remoteUrl: (->
    "/tasks/#{this.get('taskId')}/non_collaborators/%QUERY"
  ).property()

  actions:
    addParticipant: (newParticipant) ->
      @sendAction("onSelect", newParticipant.object.get('id'))
