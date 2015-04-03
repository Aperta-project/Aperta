`import TaskController from 'tahi/pods/task/controller'`

RegisterDecisionOverlayController = TaskController.extend
  isEditable: (->
    !@get("model.completed")
  ).property('model.completed')

  latestDecision: (->
    @get('model.decisions.firstObject')
  ).property('model.decisions.@each')

  previousDecisions: (->
    @get('model.decisions').sortBy('revisionNumber').reverse()[1..-1]
  ).property('model.decisions.@each')

  # implicit computed state based on .verdict
  finalDecision: (->
    @get("latestDecision.verdict") == "accepted" ||
    @get("latestDecision.verdict") == "rejected"
  ).property("latestDecision")

  saveModel: ->
    @_super()
      .then () =>
        @send("saveLatestDecision")

  actions:
    saveLatestDecision: ->
      @get('latestDecision').save().then =>
        @set 'isSavingData', false

    setDecisionTemplate: (decision) ->
      @set "isSavingData", true
      @get("latestDecision").set "verdict", decision
      @get("latestDecision").set "letter", @get("model.#{decision}LetterTemplate")

      @send("saveLatestDecision")

`export default RegisterDecisionOverlayController`
