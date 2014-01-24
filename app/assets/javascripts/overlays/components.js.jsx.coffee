###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.components ||= {}

Tahi.overlays.components.Overlay = React.createClass
  render: ->
    OverlayHeader = Tahi.overlays.components.OverlayHeader
    OverlayFooter = Tahi.overlays.components.OverlayFooter

    checkboxFormAction = "#{this.props.taskPath}.json"
    `<div>
      <OverlayHeader
        paperTitle={this.props.paperTitle}
        paperPath={this.props.paperPath}
        closeCallback={this.props.onOverlayClosed} />
      {this.props.children}
      <OverlayFooter
        closeCallback={this.props.onOverlayClosed}
        checkboxFormAction={checkboxFormAction}
        taskCompleted={this.props.taskCompleted}
        onCompletedChanged={this.props.onCompletedChanged} />
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

Tahi.overlays.components.OverlayHeader = React.createClass
  render: ->
    `<header>
      <h2><a href={this.props.paperPath}>{this.props.paperTitle}</a></h2>
      <a className="primary-button" onClick={this.props.closeCallback}>Close</a>
    </header>`

Tahi.overlays.components.OverlayFooter = React.createClass
  render: ->
    CompletedCheckbox = Tahi.overlays.components.CompletedCheckbox
    `<footer>
      <div className="content">
        <CompletedCheckbox action={this.props.checkboxFormAction} taskCompleted={this.props.taskCompleted} onSuccess={this.props.onCompletedChanged} />
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
