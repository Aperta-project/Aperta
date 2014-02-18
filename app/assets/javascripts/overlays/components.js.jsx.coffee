###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.components ||= {}

Tahi.overlays.components.Overlay = React.createClass
  getInitialState: ->
    {}

  componentWillMount: ->
    @setState @props

  componentDidMount: ->
    $.get @props.taskPath, @updateState, 'json'

  updateState: (data) ->
    @setState data

  render: ->
    OverlayHeader = Tahi.overlays.components.OverlayHeader
    OverlayFooter = Tahi.overlays.components.OverlayFooter
    updateTaskPath = "#{this.state.taskPath}.json"
    `<div>
      <OverlayHeader
        paperTitle={this.state.paperTitle}
        paperPath={this.state.paperPath}
        closeCallback={this.state.onOverlayClosed} />
      {this.props.componentToRender(this.state)}
      <OverlayFooter
        closeCallback={this.state.onOverlayClosed}
        assigneeFormAction={updateTaskPath}
        checkboxFormAction={updateTaskPath}
        taskCompleted={this.state.taskCompleted}
        onCompletedChanged={this.state.onCompletedChanged}
        assigneeId={this.state.assigneeId}
        assignees={this.state.assignees} />
    </div>`

Tahi.overlays.components.RailsForm = React.createClass
  getDefaultProps: ->
    method: 'patch'

  render: ->
    RailsFormHiddenDiv = Tahi.overlays.components.RailsFormHiddenDiv
    `<form accept-charset="UTF-8" action={this.props.action} data-remote="true" method="post">
      <RailsFormHiddenDiv method={this.props.method} />
      {this.props.children}
    </form>`

Tahi.overlays.components.CompletedCheckbox = React.createClass
  render: ->
    RailsForm = Tahi.overlays.components.RailsForm
    inputId = "task_checkbox_completed"
    `<RailsForm action={this.props.action}>
        <div>
          <input name="task[completed]" type="hidden" value="0" />
          <input id={inputId} name="task[completed]" type="checkbox" value="1" defaultChecked={this.props.taskCompleted} />
          <label htmlFor={inputId}>Completed</label>
        </div>
      </RailsForm>`

  componentDidUpdate: (prevProps, prevState, rootNode) ->
    Tahi.setupSubmitOnChange $(rootNode), $('input[type="checkbox"]', rootNode), success: @props.onSuccess

  componentDidMount: (rootNode) ->
    Tahi.setupSubmitOnChange $(rootNode), $('input[type="checkbox"]', rootNode), success: @props.onSuccess

Tahi.overlays.components.AssigneeDropDown = React.createClass
  render: ->
    {div, label, select, option} = React.DOM

    assignees = [[null, 'Please select assignee']].concat @props.assignees
    (Tahi.overlays.components.RailsForm {action: @props.action}, [
      (label {htmlFor: "task_assignee_id"}, 'This card is owned by'),
      (Chosen {
        id: "task_assignee_id"
        name: "task[assignee_id]"
        width: "200px"
        defaultValue: @props.assigneeId },
        assignees.map (assignee) -> (option {value: assignee[0]}, assignee[1])
      )
    ])

  componentDidUpdate: (prevProps, prevState, rootNode) ->
    Tahi.setupSubmitOnChange $(rootNode), $('select', rootNode)

  componentDidMount: (rootNode) ->
    Tahi.setupSubmitOnChange $(rootNode), $('select', rootNode)

Tahi.overlays.components.ProgressBar = React.createClass
  render: ->
    style = {width: "#{@props.progress}%"}
    `<div className="progress">
      <div className="progress-bar" style={style} />
     </div>`

Tahi.overlays.components.OverlayHeader = React.createClass
  render: ->
    `<header>
      <h2><a href={this.props.paperPath}>{this.props.paperTitle}</a></h2>
      <a className="primary-button" onClick={this.props.closeCallback}>Close</a>
    </header>`

Tahi.overlays.components.OverlayFooter = React.createClass
  componentDidMount: ->
    window.addEventListener 'keyup', @handleEscKey

  componentWillUnmount: ->
    window.removeEventListener 'keyup', @handleEscKey

  handleEscKey: (e) ->
    @props.closeCallback(e) if e.keyCode is 27

  render: ->
    AssigneeDropDown = Tahi.overlays.components.AssigneeDropDown
    CompletedCheckbox = Tahi.overlays.components.CompletedCheckbox

    assigneeDropDown = if @props.assignees?.length > 0
      `<AssigneeDropDown action={this.props.assigneeFormAction} assigneeId={this.props.assigneeId} assignees={this.props.assignees} />`

    `<footer>
      <div className="content">
        <div className="assignee-drop-down">
          {assigneeDropDown}
        </div>
        <div className="completed-checkbox">
          <CompletedCheckbox action={this.props.checkboxFormAction} taskCompleted={this.props.taskCompleted} onSuccess={this.props.onCompletedChanged} />
        </div>
      </div>
      <a className="primary-button" onClick={this.props.closeCallback}>Close</a>
    </footer>`

Tahi.overlays.components.RailsFormHiddenDiv = React.createClass
  render: ->
    style = {margin: 0, padding: 0, display: "inline"}
    `<div style={style}>
      <input name="utf8" type="hidden" value="✓" />
      <input name="_method" type="hidden" value={this.props.method} />
    </div>`
