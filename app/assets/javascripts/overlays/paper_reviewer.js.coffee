window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.paperReviewer =
  Overlay: React.createClass
    componentWillMount: ->
      @setState @props

    componentWillReceiveProps: (nextProps) ->
      @setState nextProps

    render: ->
      {main, h1, select, option, input, label} = React.DOM
      RailsForm = Tahi.overlays.components.RailsForm

      (main {}, [
        (h1 {}, @props.taskTitle),
        (RailsForm {action: @props.taskPath, ref: 'myForm'}, [
          (input {type: 'hidden', name: "task[paper_roles][]", value: null}),
          (label {htmlFor: 'task_paper_roles'}, 'Reviewers'),
          (Chosen {
             id: 'task_paper_roles',
             multiple: 'multiple',
             name: "task[paper_roles][]",
             value: @state.reviewerIds,
             onChange: @handleChange,
             width: "200px"},
            (@props.reviewers || []).map (reviewer) ->
              (option {value: reviewer[0]}, reviewer[1]))])])

    handleChange: (e) ->
      @setState reviewerIds: $(e.target).val()
      @refs.myForm.submit()
