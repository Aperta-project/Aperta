###* @jsx React.DOM ###

Tahi.overlays.components.Overlay = React.createClass
  displayName: "Overlay"
  getInitialState: ->
    {loading: true}

  componentWillMount: ->
    @setState @props

  componentDidMount: ->
    $.get @props.taskPath, @updateState, 'json'

  updateState: (data) ->
    data.loading = false
    @setState data

  render: ->
    OverlayHeader = Tahi.overlays.components.OverlayHeader
    OverlayFooter = Tahi.overlays.components.OverlayFooter
    updateTaskPath = "#{this.state.taskPath}.json"
    if @state.loading
      `<div className='loading'><h1>Loading&hellip;</h1></div>`
    else
      `<div className={this.props.cardName + "-overlay"}>
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
