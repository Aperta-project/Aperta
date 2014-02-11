window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.registerDecision =
  init: ->
    Tahi.overlay.init 'register-decision'

  createComponent: (target, props) ->
    props.decision = target.data('decision')
    props.decisionLetter = target.data('decisionLetter')
    props.decisionLetters = target.data('decisionLetters')
    Tahi.overlays.registerDecision.components.RegisterDecisionOverlay props

  components:
    RegisterDecisionOverlay: React.createClass
      getInitialState: ->
        decisionLetter: null

      componentWillMount: ->
        @setState
          decisionLetter: this.props.decisionLetter
          decision: this.props.decision

      render: ->
        {main, h1, div, p, label, input, textarea} = React.DOM
        Overlay = Tahi.overlays.components.Overlay
        RailsForm = Tahi.overlays.components.RailsForm

        (Overlay @props.overlayProps,
          (main {}, [
            (h1 {}, @props.taskTitle),
            (RailsForm {action: @props.overlayProps.taskPath}, [
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
                  defaultValue: @state.decisionLetter})])])]))

      updateDecisionLetter: (event) ->
        textarea = $('textarea', this.getDOMNode())
        textarea.val(this.props.decisionLetters[event.target.value])
        textarea.trigger 'change'

      componentDidMount: (rootNode) ->
        form = $('main form', rootNode)
        Tahi.setupSubmitOnChange form, $('select, textarea', form)

