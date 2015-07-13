`import TaskController from 'tahi/pods/paper/task/controller'`
`import RESTless from 'tahi/services/rest-less'`

RegisterDecisionOverlayController = TaskController.extend
  latestDecision: (->
    @get('model.paper.decisions.firstObject')
  ).property("previousDecisions")

  previousDecisions: (->
    @get('model.paper.decisions').sortBy('revisionNumber').reverse()[1..-1]
  ).property('model.paper.decisions.@each.revisionNumber')

  finalDecision: (->
    @get("latestDecision.verdict") is "accepted" or @get("latestDecision.verdict") is "rejected"
  ).property("latestDecision")

  paperPublishingState: (->
    @get("model.paper.publishingState")
  ).property("model.paper")

  publishable: (->
    @get("paperPublishingState") is "submitted" and
    @get("model.completed") is false
  ).property("paperPublishingState", "model.completed")

  nonPublishable: (->
    !@get("publishable")
  ).property("publishable")

  successText: ->
    journalName = @get('model.paper.journal.name')
    "Thank you. Your changes have been sent to #{journalName}."

  saveModel: ->
    @_super()
      .then () =>
        @send("saveLatestDecision")

  actions:
    registerDecision: ->
      taskId = @get("model.id")

      RESTless.post('/api/register_decision/' + taskId + '/decide').then =>
        @set('model.completed', true)
        @send('saveModel')
        @flash.displayMessage('success', @successText())

    saveLatestDecision: ->
      @get('latestDecision').save().then =>
        @set 'isSavingData', false

    setDecisionTemplate: (decision) ->
      @set "isSavingData", true
      @get("latestDecision").set "verdict", decision
      @get("latestDecision").set "letter", @get("model.#{decision}LetterTemplate")

      @send("saveLatestDecision")

`export default RegisterDecisionOverlayController`
