ETahi.ParticipantSelectorComponent = Ember.Component.extend
  everyone: []
  currentParticipants: []
  availableParticipants: Ember.computed.setDiff('everyone', 'currentParticipants')

  actions:
    removeParticipant: (participant) ->
      @currentParticipants.removeObject(participant)
      @sendAction("onRemove", participant)
    addParticipant: (newParticipant) ->
      @sendAction("onSelect", newParticipant.object)
