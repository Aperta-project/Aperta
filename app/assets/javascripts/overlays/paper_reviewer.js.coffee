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
        Overlay = Tahi.overlays.components.Overlay
        RailsForm = Tahi.overlays.components.RailsForm

        (Overlay @props.overlayProps,
          (main {}, [
            (h1 {}, @props.taskTitle),
            (RailsForm {action: @props.overlayProps.taskPath}, [
              (input {type: 'hidden', name: "task[paper_roles][]", value: null}),
              (label {htmlFor: 'task_paper_roles'}, 'Reviewers'),
              (select {
                 id: 'task_paper_roles',
                 multiple: 'multiple',
                 name: "task[paper_roles][]",
                 className: "chosen-select",
                 defaultValue: @props.reviewerIds},
                @props.reviewers.map (reviewer) ->
                  (option {value: reviewer[0]}, reviewer[1]))])]))

      componentDidMount: (rootNode) ->
        form = $('main form', rootNode)
        Tahi.setupSubmitOnChange form, $('select', form)
