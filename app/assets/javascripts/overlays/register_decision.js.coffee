window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.registerDecision =
  Overlay: React.createClass
    getInitialState: ->
      decisionLetters: null

    componentWillReceiveProps: (nextProps) ->
      @setState
        decisionLetters: nextProps.decisionLetters
        decision: nextProps.decision

    render: ->
      {main, h1, div, p, label, input, textarea} = React.DOM
      RailsForm = Tahi.overlays.components.RailsForm

      (main {}, [
        (h1 {}, @props.taskTitle),
        (RailsForm {action: @props.taskPath}, [
          (div {className: 'decision-selections'}, [
            (div {className: 'form-group'}, [
              (input {
                id: 'accepted_option',
                name: 'task[paper_decision]',
                type: 'radio',
                onChange: @updateDecisionLetter,
                defaultValue: 'Accepted',
                defaultChecked: @state.decision == 'Accepted'}),
              ' ',
              (label {className: 'decision-label', htmlFor: 'accepted_option'}, 'Accepted')]),
            (div {className: 'form-group'}, [
              (input {
                id: 'rejected_option',
                name: 'task[paper_decision]',
                type: 'radio',
                onChange: @updateDecisionLetter,
                defaultValue: 'Rejected',
                defaultChecked: @state.decision == 'Rejected'}),
              ' ',
              (label {className: 'decision-label', htmlFor: 'rejected_option'}, 'Rejected')]),
            (div {className: 'form-group'}, [
              (input {
                id: 'revise_option',
                name: 'task[paper_decision]',
                type: 'radio',
                onChange: @updateDecisionLetter,
                defaultValue: 'Revise',
                defaultChecked: @state.decision == 'Revise'}),
              ' ',
              (label {className: 'decision-label', htmlFor: 'revise_option'}, 'Revise')])]),
          (div {className: 'form-group'}, [
            (p {}, 'Feel free to modify the standard decision letter. Your changes will be saved.'),
            (textarea {
              id: 'task_paper_decision_letter',
              name: 'task[paper_decision_letter]',
              placeholder: 'A boilerplate decision letter will appear here.',
              defaultValue: @state.decisionLetter})])])])

    updateDecisionLetter: (event) ->
      textarea = $('textarea', this.getDOMNode())
      textarea.val @state.decisionLetters[event.target.value]
      textarea.trigger 'change'

    submitFormsOnChange: (rootNode) ->
      form = $('form', rootNode)
      Tahi.setupSubmitOnChange form, $('input, textarea', form)

    componentDidUpdate: (prevProps, prevState, rootNode) ->
      @submitFormsOnChange(rootNode)

    componentDidMount: (rootNode) ->
      @submitFormsOnChange(rootNode)

