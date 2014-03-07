###* @jsx React.DOM ###

Tahi.overlays.components.OverlayHeader = React.createClass
  displayName: "OverlayHeader"
  render: ->
    `<header>
      <h2><a href={this.props.paperPath}>{this.props.paperTitle}</a></h2>
      <a className="primary-button" onClick={this.props.closeCallback}>Close</a>
    </header>`
