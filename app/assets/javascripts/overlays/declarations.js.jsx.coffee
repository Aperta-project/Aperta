###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.declarations =
  init: ->
    Tahi.overlay.init 'declarations', @createComponent

  createComponent: (target, props) ->
    props.declarations = target.data('declarations')
    Tahi.overlays.declarations.components.DeclarationsOverlay props

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
        Overlay = Tahi.overlays.components.Overlay
        RailsForm = Tahi.overlays.components.RailsForm

        formAction = "#{this.props.paperPath}.json"
        checkboxFormAction = "#{this.props.taskPath}.json"
        `<Overlay
            declarations={this.props.declarations}
            paperTitle={this.props.paperTitle}
            paperPath={this.props.paperPath}
            closeCallback={Tahi.overlays.declarations.hideOverlay}
            taskPath={this.props.taskPath}
            taskCompleted={this.props.taskCompleted}
            onCompletedChanged={this.props.onCompletedChanged}>
          <main>
            <h1>Declarations</h1>
            <RailsForm action={formAction}>
              {this.declarations()}
            </RailsForm>
          </main>
        </Overlay>`

      componentDidMount: (rootNode) ->
        form = $('form', rootNode)
        Tahi.setupSubmitOnChange form, $('textarea', form)
