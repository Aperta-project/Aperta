###* @jsx React.DOM ###

window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.authors =
  init: ->
    Tahi.overlay.init 'authors', @createComponent

  createComponent: (target, props) ->
    props.authors = target.data('authors')
    Tahi.overlays.authors.components.AuthorsOverlay props

  components:
    AuthorsOverlay: React.createClass
      getInitialState: ->
        authors: []

      componentWillMount: ->
        @setState authors: @props.authors

      render: ->
        Overlay = Tahi.overlays.components.Overlay
        AuthorDetails = Tahi.overlays.authors.components.AuthorDetails
        AuthorDetailsForm = Tahi.overlays.authors.components.AuthorDetailsForm

        authors = @state.authors.map (author, index) =>
          if author.edit
            handler = @updateAuthor
            `<AuthorDetailsForm key={index} author={author} handleSubmit={handler} />`
          else
            `<AuthorDetails key={index} author={author} />`

        `<Overlay
            paperTitle={this.props.paperTitle}
            paperPath={this.props.paperPath}
            closeCallback={Tahi.overlays.figures.hideOverlay}
            taskPath={this.props.taskPath}
            taskCompleted={this.props.taskCompleted}
            onOverlayClosed={this.props.onOverlayClosed}
            onCompletedChanged={this.props.onCompletedChanged}>
          <main>
            <h1>Authors</h1>
            <a href="#" className='btn btn-default btn-xs' onClick={this.addNew}>
              <span className="glyphicon glyphicon-plus-sign" />
              Add new
            </a>
            <ul className='authors'>
              {authors}
            </ul>
          </main>
        </Overlay>`

      addNew: (e) ->
        e.preventDefault()
        authors = @state.authors
        @setState authors: authors.concat([edit: true])

      updateAuthor: (key, author) ->
        authors = @state.authors
        author.edit = false
        authors[key] = author
        authors = authors.map (author) ->
          first_name: author.first_name
          last_name: author.last_name
          affiliation: author.affiliation
          email: author.email
        $.ajax
          url: "#{@props.paperPath}.json"
          method: 'POST'
          data:
            _method: 'patch'
            paper:
              authors: JSON.stringify(authors)
        @setState authors: authors
        Tahi.pubsub.publish 'update_authors', authors

      componentWillUnmount: ->
        $("[data-card-name='authors']").data('authors', @state.authors)

    AuthorDetails: React.createClass
      render: ->
        `<li className='author'>
          <h4>
            <span className="author-first-name">{this.props.author.first_name}</span>
            {' '}
            <span className="author-last-name">{this.props.author.last_name}</span>
          </h4>
          <h4 className="author-email">{this.props.author.email}</h4>
          <h4 className="author-affiliation">{this.props.author.affiliation}</h4>
        </li>`

    AuthorDetailsForm: React.createClass
      render: ->
        `<li className='author'>
          <div className="form-group form-inline">
            <div className="form-group">
              <input className="form-control" ref="firstName" placeholder="First name" type="text" defaultValue={this.props.author.first_name} />
            </div>
            {' '}
            <div className="form-group">
              <input className="form-control" ref="lastName" placeholder="Last name" type="text" defaultValue={this.props.author.last_name} />
            </div>
          </div>
          <div className="form-group">
            <input className="form-control" ref="email" placeholder="Email" type="text" defaultValue={this.props.author.email} />
          </div>
          <div className="form-group form-inline">
            <div className="form-group">
              <input className="form-control" ref="affiliation" placeholder="Affiliation" type="text" defaultValue={this.props.author.affiliation} />
            </div>
            {' '}
            <div className="form-group">
              <input className="btn btn-primary" type="submit" value="done" onClick={this.handleSubmit} />
            </div>
          </div>
        </li>`

      handleSubmit: (e) ->
        e.preventDefault()
        author =
          first_name: @refs.firstName.getDOMNode().value.trim()
          last_name: @refs.lastName.getDOMNode().value.trim()
          email: @refs.email.getDOMNode().value.trim()
          affiliation: @refs.affiliation.getDOMNode().value.trim()
        @props.handleSubmit @props.key, author
