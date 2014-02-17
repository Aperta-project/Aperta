window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.paperReviewer =
  Overlay: React.createClass
    render: ->
      {main, h1, select, option, input, label} = React.DOM
      RailsForm = Tahi.overlays.components.RailsForm

      (main {}, [
        (h1 {}, @props.taskTitle),
        (RailsForm {action: @props.taskPath}, [
          (input {type: 'hidden', name: "task[paper_roles][]", value: null}),
          (label {htmlFor: 'task_paper_roles'}, 'Reviewers'),
          (Chosen {
             id: 'task_paper_roles',
             multiple: true,
             name: "task[paper_roles][]",
             width: "200px",
             defaultValue: @props.reviewerIds},
            (@props.reviewers || []).map (reviewer) ->
              (option {value: reviewer[0]}, reviewer[1]))])])

    submitFormsOnChange: (rootNode) ->
      form = $('form', rootNode)
      Tahi.setupSubmitOnChange form, $('select', form)

    componentDidMount: (rootNode) ->
      @submitFormsOnChange(rootNode)

    componentDidUpdate: (prevProps, prevState, rootNode) ->
      @submitFormsOnChange(rootNode)
