###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.components ||= {}

Tahi.overlays.components.RailsForm = React.createClass
  render: ->
    RailsFormHiddenDiv = Tahi.overlays.components.RailsFormHiddenDiv
    `<form accept-charset="UTF-8" action={this.props.action} data-remote="true" method="post">
      <RailsFormHiddenDiv method="patch" />
      {this.props.formContent}
    </form>`

Tahi.overlays.components.CompletedCheckbox = React.createClass
  formContent: ->
    taskId = 14
    inputId = "task_#{taskId}_completed"
    checkBox = if @props.taskCompleted
                 `<input id={inputId} name="task[completed]" type="checkbox" value="1" checked="checked" />`
               else
                 `<input id={inputId} name="task[completed]" type="checkbox" value="1" />`

    `<div>
      <input name="task[completed]" type="hidden" value="0" />
      {checkBox}
      <label htmlFor={inputId}>Completed</label>
    </div>`

  render: ->
    action = '/form/action'
    RailsForm = Tahi.overlays.components.RailsForm
    `<RailsForm action={action} formContent={this.formContent()} />`

  componentDidMount: (rootNode) ->
    Tahi.setupSubmitOnChange $(rootNode), $('input[type="checkbox"]', rootNode)

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
        <CompletedCheckbox />
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
