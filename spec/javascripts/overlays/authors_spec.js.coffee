beforeEach ->
  $('#jasmine_content').empty()

describe "Tahi.overlays.authors", ->
  describe "AuthorsOverlay component", ->
    describe "#getInitialState", ->
      it "returns an object with authors set to the empty array", ->
        component = Tahi.overlays.authors.Overlay()
        expect(component.getInitialState()).toEqual authors: []

    describe "#componentWillReceiveProps", ->
      it "sets state.authors to props.authors", ->
        authors = jasmine.createSpy 'props.authors'
        component = Tahi.overlays.authors.Overlay authors: authors
        spyOn component, 'setState'
        component.componentWillReceiveProps({authors: authors})
        expect(component.setState).toHaveBeenCalledWith authors: authors

      context "when props.authors is falsy", ->
        it "sets state.authors to the empty list", ->
          component = Tahi.overlays.authors.Overlay()
          spyOn component, 'setState'
          component.componentWillReceiveProps({authors: null})
          expect(component.setState).toHaveBeenCalledWith authors: []

    describe "#render", ->
      beforeEach ->
        @authors = [
            { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
            { first_name: "Nikola", last_name: "Tesla", affiliation: "Wardenclyffe", email: "" }
          ]
        @component = Tahi.overlays.authors.Overlay()
        @component.state =
          authors: @authors

      it "renders a 'Add new' button", ->
        overlay = @component.render()
        button = overlay.props.children[1]
        expect(button.props.children[1].trim()).toEqual "Add new"
        expect(button.props.onClick).toEqual @component.addNew

      it "renders an AuthorDetails component for every author", ->
        overlay = @component.render()
        authorDetails1 = overlay.props.children[2].props.children[0]
        authorDetails2 = overlay.props.children[2].props.children[1]

        AuthorDetails = Tahi.overlays.authors.AuthorDetails
        expect(authorDetails1.constructor).toEqual AuthorDetails.componentConstructor
        expect(authorDetails1.props.author).toEqual @authors[0]
        expect(authorDetails2.constructor).toEqual AuthorDetails.componentConstructor
        expect(authorDetails2.props.author).toEqual @authors[1]

    describe "#addNew", ->
      beforeEach ->
        @authors = [one: 1, two: 2]
        @component = Tahi.overlays.authors.Overlay()
        @component.state =
          authors: @authors
        spyOn @component, 'setState'
        @event = jasmine.createSpyObj 'event', ['preventDefault']

      it "appends an empty author with edit set to true", ->
        @component.addNew @event
        expect(@component.setState).toHaveBeenCalledWith authors: @authors.concat([edit: true])

      it "prevents event propagation", ->
        @component.addNew @event
        expect(@event.preventDefault).toHaveBeenCalled()

    describe "#updateAuthor", ->
      beforeEach ->
        @component = Tahi.overlays.authors.Overlay
          paperPath: '/path/to/paper'
        @component.state =
          authors: [
            { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
            { first_name: "Nikola", last_name: "Tesla", affiliation: "Wardenclyffe", email: "", edit: true }
          ]
        spyOn @component, 'setState'
        spyOn $, 'ajax'

      it "updates the author at the given index, setting edit to false", ->
        @component.updateAuthor 1, first_name: 'Nick', last_name: 'Frost', affiliation: 'North Pole', email: 'cold@example.com', edit: true
        expect(@component.setState).toHaveBeenCalledWith
          authors: [
            { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
            { first_name: "Nick", last_name: "Frost", affiliation: "North Pole", email: "cold@example.com" }
          ]

      it "sends all authors to the server via AJAX", ->
        @component.updateAuthor 1, first_name: 'Nick', last_name: 'Frost', affiliation: 'North Pole', email: 'cold@example.com', edit: true
        expect($.ajax).toHaveBeenCalledWith
          url: '/path/to/paper.json'
          method: 'POST'
          data:
            _method: 'patch'
            paper:
              authors: JSON.stringify([
                { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
                { first_name: "Nick", last_name: "Frost", affiliation: "North Pole", email: "cold@example.com" }
              ])
      it "publishes on the update_authors topic", ->
        spyOn(Tahi.pubsub, "publish")
        @component.updateAuthor 1, first_name: 'Nick', last_name: 'Frost', affiliation: 'North Pole', email: 'cold@example.com', edit: true
        expect(Tahi.pubsub.publish).toHaveBeenCalledWith 'update_authors', [
          { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
          { first_name: "Nick", last_name: "Frost", affiliation: "North Pole", email: "cold@example.com" }
        ]

  describe "AuthorDetailsForm component", ->
    describe "#handleSubmit", ->
      beforeEach ->
        @handleSubmit = jasmine.createSpy 'handleSubmit'
        @component = Tahi.overlays.authors.AuthorDetailsForm
          key: 134
          author: {}
          handleSubmit: @handleSubmit
        @event = jasmine.createSpyObj 'event', ['preventDefault']
        React.renderComponent @component, document.getElementById('jasmine_content')

      it "prevents default on the event", ->
        @component.handleSubmit @event
        expect(@event.preventDefault).toHaveBeenCalled()

      it "invokes icecream with its key and form data", ->
        @component.refs.firstName.getDOMNode().value = 'Bob'
        @component.refs.lastName.getDOMNode().value = 'Barker'
        @component.refs.email.getDOMNode().value = 'bob@example.com'
        @component.refs.affiliation.getDOMNode().value = 'The Price is Right'

        @component.handleSubmit @event
        expect(@handleSubmit).toHaveBeenCalledWith 134, {
          first_name: 'Bob', last_name: 'Barker', email: 'bob@example.com', affiliation: 'The Price is Right'
        }
