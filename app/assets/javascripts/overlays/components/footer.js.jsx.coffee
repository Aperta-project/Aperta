###* @jsx React.DOM ###

Tahi.overlays.components.OverlayFooter = React.createClass
  displayName: "OverlayFooter"
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
