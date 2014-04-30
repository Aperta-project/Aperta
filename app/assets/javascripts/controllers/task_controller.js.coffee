ETahi.TaskController = Ember.ObjectController.extend
  needs: ['application']
  onClose: 'closeOverlay'
  isLoading: false

  addSave: ( ->
    self = @
    @.saveModel = ( ->
      self.send('saveModel')
    )
  ).on('init')

  actions:
    saveModel: ->
      @get('model').save()

    closeAction: ->
      @send(@get('onClose'))

    redirect: ->
      @transitionToRoute.apply(this, @get('controllers.application.overlayRedirect'))
