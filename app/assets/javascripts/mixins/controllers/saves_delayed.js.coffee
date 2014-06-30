ETahi.SavesDelayed = Ember.Mixin.create
  saveInFlight: false

  saveDelayed: ->
    Ember.run.debounce(@, @saveModel, 100)

  saveModel: ->
    unless @get('saveInFlight')
      @set('saveInFlight', true)
      @get('model').save().then =>
        @set('saveInFlight', false)

  actions:
    saveModel: ->
      @saveDelayed()
