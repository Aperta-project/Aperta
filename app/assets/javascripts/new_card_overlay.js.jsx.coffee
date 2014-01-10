###* @jsx React.DOM ###

window.Tahi ||= {}

$(document).ready ->
  $('.react-new-card-overlay').on 'click', Tahi.newCardOverlay

Tahi.components ||= {}

Tahi.newCardOverlay = (e) ->
  e.preventDefault()

  NewCardForm = React.createClass
    submit: ->
      title = this.refs.task_title.getDOMNode().value.trim()
      assignee_id = this.refs.task_assignee_id.getDOMNode().value.trim()
      body = this.refs.task_body.getDOMNode().value.trim()

      # AJAX

    render: ->
      options = this.props.assignees.map (a) ->
        `<option value={a[0]}>{a[1]}</option>`

      `<form>
        <div className="form-group">
          <input type="text" placeholder="Type a short card title here" ref="task_title" />
        </div>
        <div className="form-group">
          <label htmlFor="task_assignee_id">Assignee</label>
          <select className="chosen-select" id="task_assignee_id" ref="task_assignee_id">
            <option value="">Please select assignee</option>
            {options}
          </select>
        </div>
        <div className="form-group">
          <textarea placeholder="Provide some details here" ref="task_body"></textarea>
        </div>
      </form>`

  Tahi.components.NewCardForm = NewCardForm

  NewCardOverlay = React.createClass
    submitForm: (e) ->
      e.preventDefault()
      @form.submit()

    render: ->
      @form = `<NewCardForm assignees={this.props.assignees} />`

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

  Tahi.components.NewCardOverlay = NewCardOverlay

  assignees = $(e.target).data('assignees')
  React.renderComponent `<NewCardOverlay assignees={assignees} />`, document.getElementById('new-overlay'), Tahi.initChosen
  $('#new-overlay').show()
