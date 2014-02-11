###* @jsx React.DOM ###

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
        Overlay = Tahi.overlays.components.Overlay
        RailsForm = Tahi.overlays.components.RailsForm

        checkboxFormAction = "#{this.props.taskPath}.json"
        options = @props.assignees.map (a) ->
          `<option value={a[0]}>{a[1]}</option>`
        `<Overlay
            decisionLetters={this.props.decisionLetters}
            paperTitle={this.props.paperTitle}
            paperPath={this.props.paperPath}
            closeCallback={Tahi.overlays.registerDecision.hideOverlay}
            taskPath={this.props.taskPath}
            taskCompleted={this.props.taskCompleted}
            assigneeId={this.props.assigneeId}
            assignees={this.props.assignees}
            onOverlayClosed={this.props.onOverlayClosed}
            onCompletedChanged={this.props.onCompletedChanged}>
          <main>
            <h1>{this.props.tasktitle}</h1>
            <RailsForm action={this.props.taskPath}>
              <div className="decision-selections">
                <div className="form-group">
                  <input onChange={this.updateDecisionLetter} id="accepted_option" name="task[paper_decision]" type="radio" defaultValue="Accepted" defaultChecked={this.state.decision === 'Accepted'} />
                  {' '}
                  <label className="decision-label" htmlFor="accepted_option">Accepted</label>
                </div>
                <div className="form-group">
                  <input onChange={this.updateDecisionLetter} id="rejected_option" name="task[paper_decision]" type="radio" defaultValue="Rejected" defaultChecked={this.state.decision === 'Rejected'} />
                  {' '}
                  <label className="decision-label" htmlFor="rejected_option">Rejected</label>
                </div>
                <div className="form-group">
                  <input onChange={this.updateDecisionLetter} id="revise_option" name="task[paper_decision]" type="radio" defaultValue="Revise" defaultChecked={this.state.decision === 'Revise'} />
                  {' '}
                  <label className="decision-label" htmlFor="revise_option">Revise</label>
                </div>
              </div>
              <div className="form-group">
                <p>Feel free to modify the standard decision letter. Your changes will be saved.</p>
                <textarea placeholder="A boilerplate decision letter will appear here." id="task_paper_decision_letter" name="task[paper_decision_letter]">{this.state.decisionLetter}</textarea>
              </div>
            </RailsForm>
          </main>
        </Overlay>`

      updateDecisionLetter: (event) ->
        textarea = $('textarea', this.getDOMNode())
        textarea.val(this.props.decisionLetters[event.target.value])
        textarea.trigger 'change'

      componentDidMount: (rootNode) ->
        form = $('main form', rootNode)
        Tahi.setupSubmitOnChange form, $('select, textarea', form)

