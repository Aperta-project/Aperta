`import TaskController from 'tahi/pods/paper/task/controller'`

ReviewerReportOverlayController = TaskController.extend
  overlayClass: 'reviewer-form'
  latestDecision: Em.computed.alias 'model.paper.latestDecision'
  previousDecisions: Em.computed 'model.paper.decisions', ->
    @get('model.paper.decisions').without @get('latestDecision')

`export default ReviewerReportOverlayController`
