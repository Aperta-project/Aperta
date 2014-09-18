ETahi.ParticipantSelectorComponent = Ember.Component.extend
  everyone: []
  currentParticipants: []
  availableParticipants: Ember.computed.setDiff('everyone', 'currentParticipants')

  actions:
    addParticipant: (newParticipant) ->
      @sendAction("onSelect", newParticipant.object)
