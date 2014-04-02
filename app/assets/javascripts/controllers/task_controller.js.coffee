ETahi.TaskController = Ember.ObjectController.extend
  needs: ['application']
  paper: Ember.computed.alias('model.phase.paper')
  onClose: 'closeOverlay'
  actions:
    saveModel: ->
      @get('model').save()

    closeAction: ->
      @send(@get('onClose'))

    redirect: ->
      @transitionToRoute.apply(this, @get('controllers.application.overlayRedirect'))


  saveOnCompletedChange: (->
    return unless @get('model.isDirty')
    @get('model').save()
  ).observes('model.completed')
