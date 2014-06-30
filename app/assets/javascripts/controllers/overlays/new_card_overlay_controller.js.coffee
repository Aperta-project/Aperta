ETahi.NewCardOverlayController = Ember.Controller.extend ETahi.ControllerParticipants,
  needs: ['application']
  error: Em.computed.alias 'controllers.application.error'
  overlayClass: 'new-adhoc-overlay'

  actions:
    cancel: ->
      @get('model').deleteRecord()
      @send('closeOverlay')

    createCard: ->
      @get('model').save().then (model) =>
        model.get('phase.tasks').pushObject(model)
        @send 'closeOverlay'
        @set 'error', null
      .catch (res) =>
        @set 'error', "Title " + res.errors.title[0] if res.errors.title
