`import TaskController from 'tahi/pods/task/controller'`

ReviewerReportOverlayController = TaskController.extend
  overlayClass: 'reviewer-form'
  latestDecision: Em.computed.alias 'model.paper.latestDecision'

`export default ReviewerReportOverlayController`
