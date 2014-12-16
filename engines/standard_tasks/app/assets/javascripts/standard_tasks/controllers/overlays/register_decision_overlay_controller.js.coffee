ETahi.RegisterDecisionOverlayController = ETahi.TaskController.extend
  actions:
    setDecisionTemplate: (decision) ->
      @set('model.paperDecisionLetter', @get("model.#{decision}LetterTemplate"))
      @set('model.paperDecision', decision)
      @get('model').save()
