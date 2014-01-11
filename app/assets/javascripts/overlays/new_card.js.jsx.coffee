###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.newCard =
  init: ->
    $('.react-new-card-overlay').on 'click', Tahi.overlays.newCard.displayNewCardOverlay

  displayNewCardOverlay: (e) ->
    e.preventDefault(e)

    assignees = $(e.target).data('assignees')
    url = $(e.target).data('url')
    phaseId = $(e.target).data('phaseId')
    NewCardOverlay = Tahi.overlays.newCard.components.NewCardOverlay
    React.renderComponent `<NewCardOverlay assignees={assignees} url={url} phaseId={phaseId} />`, document.getElementById('new-overlay'), Tahi.initChosen
    $('#new-overlay').show()

  components:
    NewCardForm: React.createClass
      submit: ->
        title = @refs.task_title.getDOMNode().value.trim()
        assigneeId = @refs.task_assignee_id.getDOMNode().value.trim()
        body = @refs.task_body.getDOMNode().value.trim()
        phaseId = @props.phaseId

        $.ajax
          url: @props.url
          method: 'POST'
          data:
            task:
              title: title
              body: body
              assignee_id: assigneeId
              phase_id: phaseId

      render: ->
        options = @props.assignees.map (a) ->
          `<option value={a[0]}>{a[1]}</option>`

        `<form>
          <div className="form-group">
            <input type="text" id="task_title" placeholder="Type a short card title here" ref="task_title" />
          </div>
          <div className="form-group">
            <label htmlFor="task_assignee_id">Assignee</label>
            <select className="chosen-select" id="task_assignee_id" ref="task_assignee_id">
              <option value="">Please select assignee</option>
              {options}
            </select>
          </div>
          <div className="form-group">
            <textarea id="task_body" placeholder="Provide some details here" ref="task_body"></textarea>
          </div>
        </form>`

    NewCardOverlay: React.createClass
      submitForm: (e) ->
        e.preventDefault()
        @form.submit()

      render: ->
        NewCardForm = Tahi.overlays.newCard.components.NewCardForm
        @form = `<NewCardForm assignees={this.props.assignees} url={this.props.url} phaseId={this.props.phaseId} />`

        `<div>
          <header>
            <h2></h2>
          </header>
          <main>
            {this.form}
          </main>
          <footer>
            <a href="#">Cancel</a>
            <a href="#" className="primary-button" onClick={this.submitForm}>Create card</a>
          </footer>
        </div>`
