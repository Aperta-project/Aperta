ETahi.RegisterDecisionOverlayController = ETahi.TaskController.extend
  actions:
    setDecisionTemplate: (decision) ->
      @setProperties
        'model.paperDecisionLetter': @get("model.#{decision}LetterTemplate")
        'model.paperDecision': decision
        'isSavingData': true

      @get('model').save().then =>
        @set 'isSavingData', false
