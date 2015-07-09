`import TaskController from 'tahi/pods/paper/task/controller'`

RegisterDecisionOverlayController = TaskController.extend
  isEditable: (->
    !@get("model.completed")
  ).property('model.completed')

  latestDecision: (->
    @get('model.paper.decisions.firstObject')
  ).property("previousDecisions")

  previousDecisions: (->
    @get('model.paper.decisions').sortBy('revisionNumber').reverse()[1..-1]
  ).property('model.paper.decisions.@each.revisionNumber')

  finalDecision: (->
    @get("latestDecision.verdict") is "accept" or @get("latestDecision.verdict") is "reject"
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
