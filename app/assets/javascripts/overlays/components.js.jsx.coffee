###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.components ||= {}

Tahi.overlays.components.OverlayHeader = React.createClass
  render: ->
    `<header>
      <h2><a href={this.props.paperPath}>{this.props.paperTitle}</a></h2>
      <a className="primary-button" onClick={this.props.closeCallback}>Close</a>
    </header>`

Tahi.overlays.components.OverlayFooter = React.createClass
  render: ->
    `<footer>
      <div className="content" />
      <a className="primary-button" onClick={this.props.closeCallback}>Close</a>
    </footer>`

Tahi.overlays.components.RailsFormHiddenDiv = React.createClass
  render: ->
    style = {margin: 0, padding: 0, display: "inline"}
    `<div style={style}>
      <input name="utf8" type="hidden" value="✓" />
      <input name="_method" type="hidden" value={this.props.method} />
    </div>`
