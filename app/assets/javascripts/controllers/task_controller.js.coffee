ETahi.TaskController = Ember.ObjectController.extend
  needs: ['application']
  onClose: 'closeOverlay'
  isLoading: false

  saveOnCompletedChange: (->
    Ember.run.once this, ->
      return unless @get('model.isDirty')
      @get('model').save()
  ).observes('model.completed')

  actions:
    saveModel: ->
      @get('model').save()

    closeAction: ->
      @send(@get('onClose'))

    redirect: ->
      @transitionToRoute.apply(this, @get('controllers.application.overlayRedirect'))
