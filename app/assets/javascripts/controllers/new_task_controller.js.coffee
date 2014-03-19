ETahi.NewTaskController = Ember.Controller.extend
  actions:
    cancel: ->
      @get('task').deleteRecord()
      @send('closeOverlay')
    createCard: ->
      @get('task').save()
      @send('closeOverlay')
