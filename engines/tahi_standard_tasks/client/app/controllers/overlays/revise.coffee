`import TaskController from 'tahi/pods/task/controller'`

ReviseOverlayController = TaskController.extend
  # isEditable: (->
  #   !@get("model.completed")
  # ).property('model.completed')

  latestDecision: (->
    debugger
    @get('model.paper.decisions.firstObject')
  ).property('model.paper.decisions.@each')

  # previousDecisions: (->
  #   @get('model.decisions').sortBy('revisionNumber').reverse()[1..-1]
  # ).property('model.decisions.@each')
  #
  # finalDecision: (->
  #   @get("latestDecision.verdict") is "accepted" or @get("latestDecision.verdict") is "rejected"
  # ).property("latestDecision")
  #
  # saveModel: ->
  #   @_super()
  #     .then () =>
  #       @send("saveLatestDecision")
  #
  # actions:
  #   saveLatestDecision: ->
  #     @get('latestDecision').save().then =>
  #       @set 'isSavingData', false
  #
  #   setDecisionTemplate: (decision) ->
  #     @set "isSavingData", true
  #     @get("latestDecision").set "verdict", decision
  #     @get("latestDecision").set "letter", @get("model.#{decision}LetterTemplate")
  #
  #     @send("saveLatestDecision")


`export default ReviseOverlayController`
