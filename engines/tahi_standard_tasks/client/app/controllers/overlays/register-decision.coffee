`import TaskController from 'tahi/pods/task/controller'`

RegisterDecisionOverlayController = TaskController.extend
  isEditable: (->
    !@get("model.completed")
  ).property('model.completed')

  actions:
    setDecisionTemplate: (decision) ->
      @setProperties
        'model.paperDecisionLetter': @get("model.#{decision}LetterTemplate")
        'model.paperDecision': decision
        'isSavingData': true

      @get('model').save().then =>
        @set 'isSavingData', false

`export default RegisterDecisionOverlayController`
