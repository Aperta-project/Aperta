`import TaskController from 'tahi/pods/paper/task/controller'`

ReviewerReportOverlayController = TaskController.extend
  overlayClass: 'reviewer-form'
  latestDecision: Em.computed.alias 'model.paper.latestDecision'
  previousDecisions: Em.computed 'model.paper.decisions', ->
    @get('model.paper.decisions').without @get('latestDecision')

  # submissionConfirmed: Em.computed.alias 'model.body.submitted'

  actions:
    confirmSubmission: ->
      @set('submissionConfirmed', true)

    cancelSubmission: ->
      @set('submissionConfirmed', false)

    submitReport: ->
      console.log @get('model.body')
      @set('model.body.submitted', true)
      @get('model').save()

`export default ReviewerReportOverlayController`
