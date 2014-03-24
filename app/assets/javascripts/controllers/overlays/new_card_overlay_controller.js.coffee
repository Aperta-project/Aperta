ETahi.NewCardOverlayController = Ember.Controller.extend
  availableParticipants: (->
    # TODO: change to users or however they want participants
    # @store.all('assignee')
    @store.all('user')
  ).property()

  actions:
    cancel: ->
      @get('model').deleteRecord()
      @send('closeOverlay')
    createCard: ->
      @get('model').save()
      @send('closeOverlay')
