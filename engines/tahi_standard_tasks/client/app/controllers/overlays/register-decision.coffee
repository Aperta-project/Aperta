`import TaskController from 'tahi/pods/task/controller'`

RegisterDecisionOverlayController = TaskController.extend
  isEditable: (->
    !@get("model.completed")
  ).property('model.completed')

  latestDecision: (->
    @get('model.decisions.firstObject')
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
      @setProperties
        'model.paperDecisionLetter': @get("model.#{decision}LetterTemplate")
        'model.paperDecision': decision
        'isSavingData': true

      @get('latestDecision').save().then =>
        @set 'isSavingData', false

`export default RegisterDecisionOverlayController`
