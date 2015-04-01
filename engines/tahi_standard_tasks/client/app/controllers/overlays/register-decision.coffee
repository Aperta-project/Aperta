`import TaskController from 'tahi/pods/task/controller'`

RegisterDecisionOverlayController = TaskController.extend
  isEditable: (->
    !@get("model.completed")
  ).property('model.completed')

  latestDecision: (->
    @get('model.decisions.firstObject') || @store.createRecord 'decision', paper: @get('model.paper')
  ).property('model.decisions.@each')

  previousDecisions: (->
    @get('model.decisions')[1..-1]
  ).property('model.decisions.@each')

  saveModel: ->
    @_super()
      .then () =>
        if @get('model.completed') and @get('latestDecision.verdict') == 'revise'
          decision = @store.createRecord 'decision',
            paper: @get('model.paper')
          decision.save().then (decision) =>
            # TODO: Set Paper.editable to true
            @set('model.completed', false)
            @get('model').save()

  actions:
    saveLatestDecision: ->
      @get('latestDecision').save().then =>
        @set 'isSavingData', false

    setDecisionTemplate: (decision) ->
      @set("isSavingData", true)
      @get("latestDecision").set "verdict", decision
      @get("latestDecision").set "letter", @get("model.#{decision}LetterTemplate")

      @get('latestDecision').save().then =>
        @set 'isSavingData', false

`export default RegisterDecisionOverlayController`
