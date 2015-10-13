`import TaskController from 'tahi/pods/paper/task/controller'`

ReviseOverlayController = TaskController.extend
  # offset by 1, since the first Decision should be an empty decision,
  # unless the paper's lifecycle is complete
  latestDecision: (->
    @get('model.paper.decisions').sortBy('revisionNumber').reverse()[1]
  ).property("previousDecisions")

  # offset by 2
  # skip the 1st empty Decision
  # latestDecision shows the last Decision that was left
  # so, start on Decision offset 2
  previousDecisions: (->
    @get('model.paper.decisions').sortBy('revisionNumber').reverse()[2..-1]
  ).property('model.paper.decisions.[]')

  editingAuthorResponse: false

  actions:

    saveAuthorResponse: ->
      @get('latestDecision').save().then =>
        @set 'editingAuthorResponse', false

    editAuthorResponse: ->
      @set 'editingAuthorResponse', true

`export default ReviseOverlayController`
