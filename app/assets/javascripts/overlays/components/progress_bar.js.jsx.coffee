###* @jsx React.DOM ###

Tahi.overlays.components.ProgressBar = React.createClass
  render: ->
    style = {width: "#{@props.progress}%"}
    `<div className="progress">
      <div className="progress-bar" style={style} />
     </div>`
