ETahi.RegisterDecisionOverlayController = ETahi.TaskController.extend
  actions:
    setDecisionTemplate: (decision) ->
      @set("paperDecision", decision)
      @set("paperDecisionLetter", @get("model.#{decision}LetterTemplate"))
      @get('model').save()

