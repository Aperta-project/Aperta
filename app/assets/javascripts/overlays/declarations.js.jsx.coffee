###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.declarations =
  init: ->
    $('[data-card-name=declarations]').on 'click', Tahi.overlays.declarations.displayOverlay

  hideOverlay: (e) ->
    e?.preventDefault()
    $('#new-overlay').hide()
    React.unmountComponentAtNode document.getElementById('new-overlay')

  displayOverlay: (e) ->
    e.preventDefault()

    $target = $(e.target)
    component = Tahi.overlays.declarations.components.DeclarationsOverlay
      paperTitle: $target.data('paperTitle')
      paperPath: $target.data('paperPath')
      taskPath: $target.data('taskPath')
      declarations: $target.data('declarations')
      taskCompleted: $target.hasClass('completed')
      onCompletedChanged: Tahi.overlays.declarations.handleCompletedChanged
    React.renderComponent component, document.getElementById('new-overlay'), Tahi.initChosen

    $('#new-overlay').show()

  handleCompletedChanged: (event, data) ->
    $('[data-card-name=declarations]').toggleClass 'completed', data.completed

  components:
    DeclarationsOverlay: React.createClass
      declarations: ->
        @props.declarations.map (declaration, index) ->
          hiddenField = if 'id' in Object.keys(declaration)
            `<input id={"paper_declarations_attributes_" + index + "_id"} name={"paper[declarations_attributes][" + index + "][id]"} type="hidden" value={declaration['id']} />`

          `<div key={index} className="form-group declaration">
            <label htmlFor={"paper_declarations_attributes_" + index + "_answer"}>{declaration['question']}</label>
            <textarea className="form-control" id={"paper_declarations_attributes_" + index + "_answer"} name={"paper[declarations_attributes][" + index + "][answer]"} rows="6" defaultValue={declaration['answer']} />
            {hiddenField}
          </div>`

      render: ->
        OverlayHeader = Tahi.overlays.components.OverlayHeader
        OverlayFooter = Tahi.overlays.components.OverlayFooter
        HiddenDivComponent = Tahi.overlays.components.RailsFormHiddenDiv

        formAction = "#{this.props.paperPath}.json"
        checkboxFormAction = "#{this.props.taskPath}.json"
        `<div>
          <OverlayHeader paperTitle={this.props.paperTitle} paperPath={this.props.paperPath} closeCallback={Tahi.overlays.declarations.hideOverlay} />
          <main>
            <h1>Declarations</h1>
            <form accept-charset="UTF-8" action={formAction} data-remote="true" method="post">
              <HiddenDivComponent method="patch" />
              {this.declarations()}
            </form>
          </main>
          <OverlayFooter closeCallback={Tahi.overlays.declarations.hideOverlay} checkboxFormAction={checkboxFormAction} taskCompleted={this.props.taskCompleted} onCompletedChanged={this.props.onCompletedChanged} />
        </div>`

      componentDidMount: (rootNode) ->
        form = $('form', rootNode)
        Tahi.setupSubmitOnChange form, $('textarea', form)
