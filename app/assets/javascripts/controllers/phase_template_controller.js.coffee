ETahi.PhaseTemplateController = Em.ObjectController.extend
  nextPosition: (->
    @get('position') + 1
  ).property('position')

  canRemoveCard: true

  actions:
    moveTaskTemplate: (taskTemplate) ->
      @send 'changeTaskPhase', taskTemplate, @get('content')
