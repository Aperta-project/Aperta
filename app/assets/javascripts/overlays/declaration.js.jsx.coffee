###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.declaration =
  init: ->
    Tahi.overlay.init 'declaration'

  createComponent: (target, props) ->
    props.declarations = target.data('declarations')
    Tahi.overlays.declaration.components.DeclarationOverlay props

  components:
    DeclarationOverlay: React.createClass
      getInitialState: ->
        declarations: []

      componentWillMount: ->
        @setState
          declarations: @props.declarations

      declarations: ->
        @props.declarations.map (declaration, index) ->
          hiddenField = if 'id' in Object.keys(declaration)
            `<input id={"paper_declarations_attributes_" + index + "_id"} name={"paper[declarations_attributes][" + index + "][id]"} type="hidden" value={declaration['id']} />`

          `<div key={index} className="form-group declaration">
            <label ref={"declaration_question_" + index} htmlFor={"paper_declarations_attributes_" + index + "_answer"}>{declaration['question']}</label>
            <textarea ref={"declaration_answer_" + index} className="form-control" id={"paper_declarations_attributes_" + index + "_answer"} name={"paper[declarations_attributes][" + index + "][answer]"} rows="6" defaultValue={declaration['answer']} />
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
            closeCallback={Tahi.overlays.declaration.hideOverlay}
            taskPath={this.props.taskPath}
            taskCompleted={this.props.taskCompleted}
            onOverlayClosed={this.props.onOverlayClosed}
            onCompletedChanged={this.props.onCompletedChanged}>
          <main>
            <h1>{this.props.tasktitle}</h1>
            <RailsForm action={formAction}>
              {this.declarations()}
            </RailsForm>
          </main>
        </Overlay>`

      componentDidMount: (rootNode) ->
        form = $('main form', rootNode)
        Tahi.setupSubmitOnChange form, $('textarea', form)

      componentWillUnmount: ->
        declarations = @props.declarations.map (declaration, index) =>
          question: @refs["declaration_question_#{index}"].props.children
          answer: @refs["declaration_answer_#{index}"].getDOMNode().value.trim()
          id: declaration.id

        $("[data-card-name='declaration']").data('declarations', declarations)
