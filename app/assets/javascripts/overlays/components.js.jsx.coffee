###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.components ||= {}

Tahi.overlays.components.Overlay = React.createClass
  render: ->
    OverlayHeader = Tahi.overlays.components.OverlayHeader
    OverlayFooter = Tahi.overlays.components.OverlayFooter

    updateTaskPath = "#{this.props.taskPath}.json"
    `<div>
      <OverlayHeader
        paperTitle={this.props.paperTitle}
        paperPath={this.props.paperPath}
        closeCallback={this.props.onOverlayClosed} />
      {this.props.children}
      <OverlayFooter
        closeCallback={this.props.onOverlayClosed}
        assigneeFormAction={updateTaskPath}
        checkboxFormAction={updateTaskPath}
        taskCompleted={this.props.taskCompleted}
        onCompletedChanged={this.props.onCompletedChanged}
        assigneeId={this.props.assigneeId}
        assignees={this.props.assignees} />
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

  componentDidMount: (rootNode) ->
    Tahi.setupSubmitOnChange $(rootNode), $('input[type="checkbox"]', rootNode), success: @props.onSuccess

Tahi.overlays.components.AssigneeDropDown = React.createClass
  render: ->
    {div, label, select, option} = React.DOM

    (Tahi.overlays.components.RailsForm {action: @props.action}, [
      (label {htmlFor: "task_assignee_id"}, 'This card is owned by'),
      (select {className: 'chosen-select', id: "task_assignee_id", name: "task[assignee_id]", defaultValue: @props.assigneeId},
        ([[null, 'Please select assignee']].concat @props.assignees).map (assignee) ->
          (option {value: assignee[0]}, assignee[1]))])

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
  render: ->
    AssigneeDropDown = Tahi.overlays.components.AssigneeDropDown
    CompletedCheckbox = Tahi.overlays.components.CompletedCheckbox

    assigneeDropDown = if @props.assignees?
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
