`import TaskController from 'tahi/pods/paper/task/controller'`

ReviewerReportOverlayController = TaskController.extend
  overlayClass: 'reviewer-form'
  latestDecision: Em.computed.alias 'model.paper.latestDecision'
  previousDecisions: Em.computed 'model.paper.decisions', ->
    @get('model.paper.decisions').without @get('latestDecision')

  actions:
    confirmSubmission: ->
      @set('submissionConfirmed', true)

    cancelSubmission: ->
      @set('submissionConfirmed', false)

    submitReport: ->
      @set('model.body.submitted', true)
      @set('model.completed', true)
      @get('model').save()

`export default ReviewerReportOverlayController`
