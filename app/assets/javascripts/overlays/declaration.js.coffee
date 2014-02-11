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
        {div, input, label, textarea} = React.DOM

        @props.declarations.map (declaration, index) ->
          hiddenField = if 'id' in Object.keys(declaration)
            (input {
              id: "paper_declarations_attributes_#{index}_id"
              name: "paper[declarations_attributes][#{index}][id]"
              type: 'hidden', value: declaration['id']})

          (div {key: index, className: 'form-group declaration'}, [
            (label {
              ref: "declaration_question_#{index}"
              htmlFor: "paper_declarations_attributes_#{index}_answer"}, declaration['question']),
            (textarea {
              ref: "declaration_answer_#{index}",
              id: "paper_declarations_attributes_#{index}_answer",
              name: "paper[declarations_attributes][#{index}][answer]",
              className: 'form-control', rows: 6
              defaultValue: declaration['answer']}),
            hiddenField])

      render: ->
        {main, h1} = React.DOM
        Overlay = Tahi.overlays.components.Overlay
        RailsForm = Tahi.overlays.components.RailsForm

        (Overlay @props.overlayProps,
          (main {}, [
            (h1 {}, @props.taskTitle),
            (RailsForm {action:  "#{@props.overlayProps.paperPath}.json"}, @declarations())]))

      componentDidMount: (rootNode) ->
        form = $('main form', rootNode)
        Tahi.setupSubmitOnChange form, $('textarea', form)

      componentWillUnmount: ->
        declarations = @props.declarations.map (declaration, index) =>
          question: @refs["declaration_question_#{index}"].props.children
          answer: @refs["declaration_answer_#{index}"].getDOMNode().value.trim()
          id: declaration.id

        $("[data-card-name='declaration']").data('declarations', declarations)
