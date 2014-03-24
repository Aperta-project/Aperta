ETahi.NewCardOverlayController = Ember.Controller.extend
  availableParticipants: (->
    @store.all('user') #simply getting all users for now
  ).property()

  actions:
    cancel: ->
      @get('model').deleteRecord()
      @send('closeOverlay')
    createCard: ->
      @get('model').save()
      @send('closeOverlay')
