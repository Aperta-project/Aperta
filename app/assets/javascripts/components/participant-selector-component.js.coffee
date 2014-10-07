ETahi.ParticipantSelectorComponent = Ember.Component.extend
  everyone: []
  currentParticipants: []
  availableParticipantsList: []

  availableParticipants: (->
    return [] if Em.isEmpty @get('everyone.content')

    currentParticipantIds = @get('currentParticipants').mapProperty('id')
    (@get('everyone.content').reject (user) ->
      currentParticipantIds.contains("" + user.id)).map (user) ->
        Ember.Object.create user
  ).property('everyone.content.[]', 'currentParticipants.@each')

  updateParticipantsList: (->
    Ember.run =>
      @set('availableParticipantsList', @get('availableParticipants'))
  ).observes('availableParticipants').on('init')

  remoteUrl: (->
    "/filtered_users/non_participants/#{@get('taskId')}/%QUERY"
  ).property()

  actions:
    addParticipant: (newParticipant) ->
      @sendAction("onSelect", newParticipant.object.get('id'))
