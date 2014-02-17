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
          (select {
             id: 'task_paper_roles',
             ref: 'reviewerSelect',
             multiple: 'multiple',
             name: "task[paper_roles][]",
             className: "chosen-select",
             defaultValue: @props.reviewerIds},
            (@props.reviewers || []).map (reviewer) ->
              (option {value: reviewer[0]}, reviewer[1]))])])

    submitFormsOnChange: (rootNode) ->
      form = $('form', rootNode)
      Tahi.setupSubmitOnChange form, $('select', form)

    componentDidMount: (rootNode) ->
      @submitFormsOnChange(rootNode)

    componentDidUpdate: (prevProps, prevState, rootNode) ->
      domNode = @refs.reviewerSelect.getDOMNode()
      $(domNode).trigger('chosen:updated')
      @submitFormsOnChange(rootNode)
