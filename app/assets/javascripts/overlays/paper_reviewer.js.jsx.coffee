###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.paperReviewer =
  init: ->
    Tahi.overlay.init 'paper-reviewer'

  createComponent: (target, props) ->
    props.reviewers = target.data('reviewers')
    props.reviewerIds = target.data('reviewer-ids')
    Tahi.overlays.paperReviewer.components.PaperReviewerOverlay props

  components:
    PaperReviewerOverlay: React.createClass
      render: ->
        {main, h1, select, option, input, label} = React.DOM
        (Tahi.overlays.components.Overlay {
            paperTitle: @props.paperTitle
            paperPath: @props.paperPath
            taskPath: @props.taskPath
            taskCompleted: @props.taskCompleted
            onOverlayClosed: @props.onOverlayClosed
            onCompletedChanged: @props.onCompletedChanged
            assigneeId: @props.assigneeId
            assignees: @props.assignees
          },
          (main {}, [
            (h1 {}, 'Assign Reviewers'),
            (Tahi.overlays.components.RailsForm {action: @props.taskPath}, [
              (input {type: 'hidden', name: "task[paper_roles][]", value: null}),
              (label {htmlFor: 'task_paper_roles'}, 'Reviewers'),
              (select {id: 'task_paper_roles', multiple: 'multiple', name: "task[paper_roles][]", className: "chosen-select", defaultValue: @props.reviewerIds},
                @props.reviewers.map (reviewer) ->
                  (option {value: reviewer[0]}, reviewer[1])
              )
            ])
          ])
        )

      componentDidMount: (rootNode) ->
        form = $('main form', rootNode)
        Tahi.setupSubmitOnChange form, $('select', form)
