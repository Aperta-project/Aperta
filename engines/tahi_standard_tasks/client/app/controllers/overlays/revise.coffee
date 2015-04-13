`import TaskController from 'tahi/pods/task/controller'`

ReviseOverlayController = TaskController.extend
  # offset by 1, since the first Decision should be an empty decision,
  # unless the paper's lifecycle is complete
  latestDecision: (->
    @get('model.decisions').sortBy('revisionNumber').reverse()[1]
  ).property('model.decisions.@each.revisionNumber')

  # offset by 2
  # skip the 1st empty Decision
  # latestDecision shows the last Decision that was left
  # so, start on Decision offset 2
  previousDecisions: (->
    @get('model.decisions').sortBy('revisionNumber').reverse()[2..-1]
  ).property('model.decisions.@each.revisionNumber')
`export default ReviseOverlayController`
