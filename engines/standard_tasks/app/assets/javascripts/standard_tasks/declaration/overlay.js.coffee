Tahi.overlays.standardsDeclaration =
  Overlay: React.createClass
    getInitialState: ->
      declarations: []

    componentWillMount: ->
      @setState @props

    componentWillReceiveProps: (nextProps) ->
      @setState nextProps

    declarations: ->
      {div, input, label, textarea} = React.DOM

      @state.declarations.map (declaration, index) =>
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
            onBlur: @submitForm,
            onChange: @updateContent,
            "data-declaration-index": index,
            name: "paper[declarations_attributes][#{index}][answer]",
            className: 'form-control', rows: 6
            value: declaration['answer']}),
          hiddenField])

    render: ->
      {main, h1} = React.DOM
      RailsForm = Tahi.overlays.components.RailsForm

      (main {}, [
        (h1 {}, @state.taskTitle),
        (RailsForm {action:  "#{@props.paperPath}.json", ref: 'form'},
          @declarations())])

    submitForm: ->
      @refs.form.submit()

    updateContent: (e) ->
      index = $(e.target).data("declarationIndex")
      newDecs = @state.declarations.slice()
      newDecs[index].answer = e.target.value
      @setState {declarations: newDecs}
