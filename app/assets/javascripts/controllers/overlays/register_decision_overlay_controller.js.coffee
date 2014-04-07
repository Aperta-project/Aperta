ETahi.RegisterDecisionOverlayController = ETahi.TaskController.extend
  actions:
    setDecisionTemplate: (paper, decision) ->
      paper.set("decision", decision)
      paper.set("decisionLetter", @get("model.#{decision}LetterTemplate"))
      paper.save()

