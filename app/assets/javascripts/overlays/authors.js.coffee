window.Tahi ||= {}

Tahi.overlays ||= {}

Tahi.overlays.authors =
  init: ->
    Tahi.overlay.init 'authors'

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
        {main, h1, a, span, ul} = React.DOM

        Overlay = Tahi.overlays.components.Overlay
        AuthorDetails = Tahi.overlays.authors.components.AuthorDetails
        AuthorDetailsForm = Tahi.overlays.authors.components.AuthorDetailsForm

        authors = @state.authors.map (author, index) =>
          if author.edit
            handler = @updateAuthor
            (AuthorDetailsForm {key: index, author: author, handleSubmit: handler})
          else
            (AuthorDetails {key: index, author: author})

        (Overlay @props.overlayProps,
          (main {}, [
            (h1 {}, @props.taskTitle),
            (a {href: '#', className: 'btn btn-default btn-xs', onClick: @addNew}, [
              (span {className: 'glyphicon glyphicon-plus-sign'}),
              'Add new']),
            (ul {className: 'authors'}, authors)]))

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
          url: "#{@props.overlayProps.paperPath}.json"
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
        {li, h4, span} = React.DOM

        (li {className: 'author'}, [
          (h4 {}, [
            (span {className: 'author-first-name'}, @props.author.first_name),
            ' ',
            (span {className: 'author-last-name'}, @props.author.last_name)]),
          (h4 {className: 'author-email'}, @props.author.email),
          (h4 {className: 'author-affiliation'}, @props.author.affiliation)])

    AuthorDetailsForm: React.createClass
      render: ->
        {li, div, input} = React.DOM

        (li {className: 'author'}, [
          (div {className: 'form-group form-inline'}, [
            (div {className: 'form-group'},
              (input {
                ref: 'firstName',
                className: 'form-control',
                placeholder: 'First name',
                type: 'text',
                defaultValue: @props.author.first_name})),
            ' ',
            (div {className: 'form-group'},
              (input {
                ref: 'lastName',
                className: 'form-control',
                placeholder: 'Last name',
                type: 'text',
                defaultValue: @props.author.last_name}))]),
          (div {className: 'form-group'},
            (input {
              ref: 'email',
              className: 'form-control',
              placeholder: 'Email',
              type: 'text',
              defaultValue: @props.author.email})),
          (div {className: 'form-group form-inline'},
            (div {className: 'form-group'},
              (input {
                ref: 'affiliation',
                className: 'form-control',
                placeholder: 'Affiliation',
                type: 'text',
                defaultValue: @props.author.affiliation}))
              ' ',
              (div {className: 'form-group'},
                (input {
                  className: 'btn-primary btn',
                  type: 'submit',
                  value: 'done',
                  onClick: @handleSubmit})))])

      handleSubmit: (e) ->
        e.preventDefault()
        author =
          first_name: @refs.firstName.getDOMNode().value.trim()
          last_name: @refs.lastName.getDOMNode().value.trim()
          email: @refs.email.getDOMNode().value.trim()
          affiliation: @refs.affiliation.getDOMNode().value.trim()
        @props.handleSubmit @props.key, author
