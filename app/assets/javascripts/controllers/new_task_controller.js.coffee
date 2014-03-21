ETahi.NewTaskController = Ember.Controller.extend
  availableParticipants: (->
    # change to users or however they want participants
    @store.all('assignee')
  ).property()
  actions:
    cancel: ->
      @get('model').deleteRecord()
      @send('closeOverlay')
    createCard: ->
      @get('model').save()
      @send('closeOverlay')
