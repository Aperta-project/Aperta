###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.reviewerReport =
  init: ->
    Tahi.overlay.init 'reviewer-report', @createComponent

  createComponent: (target, props) ->
    Tahi.overlays.reviewerReport.components.ReviewerReportOverlay props

  components:
    ReviewerReportOverlay: React.createClass
      render: ->
        {main, label, textarea} = React.DOM

        formAction = "#{@props.taskPath}.json"
        (Tahi.overlays.components.Overlay {
            onOverlayClosed: @props.onOverlayClosed
            paperTitle: @props.paperTitle
            paperPath: @props.paperPath
            closeCallback: Tahi.overlays.figures.hideOverlay
            taskPath: @props.taskPath
            taskCompleted: @props.taskCompleted
            onOverlayClosed: @props.onOverlayClosed
            onCompletedChanged: @props.onCompletedChanged
            assigneeId: @props.assigneeId
            assignees: @props.assignees
          },
          (main {}, [
            (Tahi.overlays.components.RailsForm {action: formAction}, [
              (label {htmlFor: 'task_paper_review_attributes_body'}, 'Body'),
              (textarea {id: 'task_paper_review_attributes_body', name: 'task[paper_review_attributes][body]'})
            ])
          ])
        )

      componentDidMount: (rootNode) ->
        form = $('main form', rootNode)
        Tahi.setupSubmitOnChange form, $('textarea', form)
