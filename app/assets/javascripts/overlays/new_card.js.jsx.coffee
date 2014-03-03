###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.newCard =
  hideOverlay: (e) ->
    e?.preventDefault()
    Tahi.overlay.hide()

  components:
    NewCardForm: React.createClass
      displayName: "NewCardForm"
      submit: ->
        title = @refs.task_title.getDOMNode().value.trim()
        assigneeId = @refs.task_assignee_id.getDOMNode().value.trim()
        body = @refs.task_body.getDOMNode().value.trim()
        phaseId = @props.phaseId
        $.ajax
          url: @props.url
          method: 'POST'
          success: ->
            Turbolinks.visit(window.location.pathname)
          data:
            task:
              title: title
              body: body
              assignee_id: assigneeId
              phase_id: phaseId
        Tahi.overlays.newCard.hideOverlay()

      render: ->
        options = @props.assignees.map (a) ->
          `<option value={a[0]}>{a[1]}</option>`

        `<form>
          <div className="form-group">
            <input type="text" id="task_title" placeholder="Type a short card title here" ref="task_title" />
          </div>
          <div className="form-group">
            <label htmlFor="task_assignee_id">Assign this task to:</label>
            <Chosen id="task_assignee_id" ref="task_assignee_id" width="200px">
              <option value="">Please select assignee</option>
              {options}
            </Chosen>
          </div>
          <div className="form-group">
            <textarea id="task_body" placeholder="Provide some details here" ref="task_body"></textarea>
          </div>
        </form>`

    NewCardOverlay: React.createClass
      displayName: 'NewCardOverlay'

      submitForm: (e) ->
        e.preventDefault()
        @form.submit()

      render: ->
        NewCardForm = Tahi.overlays.newCard.components.NewCardForm
        @form = `<NewCardForm assignees={this.props.assignees} url={this.props.url} phaseId={this.props.phaseId} />`

        `<div>
          <header>
            <h2>{this.props.paperShortTitle}</h2>
          </header>
          <main>
            {this.form}
          </main>
          <footer>
            <div className="content">
              <a className="close-overlay" onClick={Tahi.overlays.newCard.hideOverlay} href="#">Cancel</a>
            </div>
            <a href="#" className="primary-button" onClick={this.submitForm}>Create card</a>
          </footer>
        </div>`
