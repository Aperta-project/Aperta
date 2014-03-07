Tahi.overlays.components.AssigneeDropDown = React.createClass
  displayName: "AssigneeDropDown"

  assigneeOptions: ->
    _.map @props.assignees, (a) ->
      [a.id, a.full_name]

  render: ->
    {div, label, select, option} = React.DOM

    assignees = [[null, 'Please select assignee']].concat @assigneeOptions()
    (Tahi.overlays.components.RailsForm {action: @props.action, ref: 'form'}, [
      (label {htmlFor: "task_assignee_id"}, 'This card is owned by'),
      (Chosen {
        id: "task_assignee_id"
        name: "task[assignee_id]"
        width: "200px"
        onChange: @handleChange,
        defaultValue: @props.assigneeId },
        assignees.map (assignee) -> (option {value: assignee[0]}, assignee[1])
      )
    ])

  handleChange: (e) ->
    @refs.form.submit()

