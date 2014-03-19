ETahi.TaskController = Ember.ObjectController.extend
  paper: Ember.computed.alias('model.phase.paper')
  paperTitle: Ember.computed.alias('paper.title')
  onClose: 'closeOverlay'
  actions:
    closeAction: ->
      @send(@get('onClose'))

    showManager: ->
      @transitionToRoute('paper.manage', @get('paper'))

