###* @jsx React.DOM ###

Tahi.overlays.components.CompletedCheckbox = React.createClass
  componentWillMount: ->
    @setState taskCompleted: @props.taskCompleted

  componentWillReceiveProps: (nextProps) ->
    @setState nextProps

  completedTrigger: (event, response) ->
    @props.onSuccess(response.completed)

  render: ->
    RailsForm = Tahi.overlays.components.RailsForm
    inputId = "task_checkbox_completed"
    `<RailsForm action={this.props.action} ref='form' ajaxSuccess={this.completedTrigger}>
        <div>
          <input name="task[completed]" type="hidden" value="0" />
          <input id={inputId} name="task[completed]" type="checkbox" value="1" onChange={this.updateCompleted} checked={this.state.taskCompleted} />
          <label htmlFor={inputId}>Completed</label>
        </div>
      </RailsForm>`

  updateCompleted: (e) ->
    @setState
      taskCompleted: $(e.target).is(':checked')
    @refs.form.submit()
