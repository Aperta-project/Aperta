beforeEach ->
  $('#jasmine_content').empty()

describe "Tahi.overlays.authors", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#"
         id="link1"
         data-card-name="authors"
         data-authors="[1, 2, 3]">Foo</a>
      <a href="#"
         id="link2"
         data-card-name="authors"
         data-authors="[1, 2, 3]">Bar</a>
      <div id="new-overlay" style="display: none;"></div>

      <!-- TODO: Delete the below -->
      <ul class="authors">
      </ul>
      <a href="#" id="add-author">Add new</a>
      <div id="author-form-template">
        <b>This is a new <i>author</i></b>
      </div>
      <!-- TODO: Delete the above -->
    """

  describe "#init", ->
    it "calls Tahi.overlay.init", ->
      spyOn Tahi.overlay, 'init'
      Tahi.overlays.authors.init()
      expect(Tahi.overlay.init).toHaveBeenCalledWith 'authors', Tahi.overlays.authors.createComponent

  describe "#createComponent", ->
    it "instantiates a FiguresOverlay component", ->
      spyOn Tahi.overlays.authors.components, 'AuthorsOverlay'
      Tahi.overlays.authors.createComponent $('#link1'), one: 1, two: 2
      expect(Tahi.overlays.authors.components.AuthorsOverlay).toHaveBeenCalledWith(
        jasmine.objectContaining
          one: 1
          two: 2
          authors: [1, 2, 3]
      )

  describe "AuthorsOverlay component", ->
    describe "#getInitialState", ->
      it "returns an object with authors set to the empty array", ->
        component = Tahi.overlays.authors.components.AuthorsOverlay()
        expect(component.getInitialState()).toEqual authors: []

    describe "#componentWillMount", ->
      it "sets state.authors to props.authors", ->
        authors = jasmine.createSpy 'props.authors'
        component = Tahi.overlays.authors.components.AuthorsOverlay authors: authors
        spyOn component, 'setState'
        component.componentWillMount()
        expect(component.setState).toHaveBeenCalledWith authors: authors

    describe "#render", ->
      beforeEach ->
        @authors = [
            { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
            { first_name: "Nikola", last_name: "Tesla", affiliation: "Wardenclyffe", email: "" }
          ]
        @component = Tahi.overlays.authors.components.AuthorsOverlay()
        @component.state =
          authors: @authors

      it "renders an Overlay component wrapping our content", ->
        overlay = @component.render()
        Overlay = Tahi.overlays.components.Overlay
        expect(overlay.constructor).toEqual Overlay.componentConstructor

      it "renders a 'Add new' button", ->
        overlay = @component.render()
        button = overlay.props.children.props.children[1]
        expect(button.props.children[1].trim()).toEqual "Add new"
        expect(button.props.onClick).toEqual @component.addNew

      it "renders an AuthorDetails component for every author", ->
        overlay = @component.render()
        authorDetails1 = overlay.props.children.props.children[2].props.children[0]
        authorDetails2 = overlay.props.children.props.children[2].props.children[1]

        AuthorDetails = Tahi.overlays.authors.components.AuthorDetails
        expect(authorDetails1.constructor).toEqual AuthorDetails.componentConstructor
        expect(authorDetails1.props.author).toEqual @authors[0]
        expect(authorDetails2.constructor).toEqual AuthorDetails.componentConstructor
        expect(authorDetails2.props.author).toEqual @authors[1]

    describe "#addNew", ->
      beforeEach ->
        @authors = [one: 1, two: 2]
        @component = Tahi.overlays.authors.components.AuthorsOverlay()
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
        @component = Tahi.overlays.authors.components.AuthorsOverlay
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
        @component = Tahi.overlays.authors.components.AuthorDetailsForm
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

  describe "#oldInit", ->
    $('#jasmine_content').html """
      <ul class="authors">
      </ul>
      <a href="#" id="add-author">Add new</a>
      <div id="author-form-template">
        <b>This is a new <i>author</i></b>
      </div>
    """
    it "invokes #appendAuthorForm on 'Add new' click", ->
      spyOn Tahi.overlays.authors, 'appendAuthorForm'
      Tahi.overlays.authors.oldInit()
      $('#add-author').click()
      expect(Tahi.overlays.authors.appendAuthorForm).toHaveBeenCalled()

  describe "#appendAuthorForm", ->
    beforeEach ->
      $('#jasmine_content').html """
        <ul class="authors">
        </ul>
        <a href="#" id="add-author">Add new</a>
        <div id="author-form-template">
          <b>This is a new <i>author</i></b>
          <input name="commit" type="submit" value="done">
        </div>
      """

    it "adds a new form row", ->
      Tahi.overlays.authors.oldInit()
      expect($('li.author').length).toEqual(0)
      Tahi.overlays.authors.appendAuthorForm()
      expect($('li.author').length).toEqual(1)
      expect($('li.author').text().trim()).toEqual "This is a new author"

    it "binds #htmlify to the submit button", ->
      spyOn Tahi.overlays.authors, 'htmlify'
      Tahi.overlays.authors.oldInit()
      Tahi.overlays.authors.appendAuthorForm()
      $('input[type=submit]').click()
      expect(Tahi.overlays.authors.htmlify).toHaveBeenCalledWith($('li.author')[0])


  describe "#htmlify", ->
    it "converts the author form into html", ->
      $('#jasmine_content').html """
        <ul class="authors">
          <li class="author">
            <div class="form-group form-inline">
              <div class="form-group">
                <input class="form-control" id="author_first_name" name="author_first_name" placeholder="First name" type="text" value="Neil">
              </div>
              <div class="form-group">
                <input class="form-control" id="author_last_name" name="author_last_name" placeholder="Last name" type="text" value="Bohr">
              </div>
            </div>
            <div class="form-group">
              <input class="form-control" id="author_email" name="author_email" placeholder="Email" type="text" value="neil@example.com">
            </div>
            <div class="form-group form-inline">
              <div class="form-group">
                <input class="form-control" id="author_affiliation" name="author_affiliation" placeholder="Affiliation" type="text" value="Universitat">
              </div>
              <div class="form-group">
                <input class="btn btn-primary" name="commit" type="submit" value="done">
              </div>
            </div>
          </li>
        </ul>
      """
      Tahi.overlays.authors.htmlify($('li.author')[0])
      expect($('li.author h4 .author-first-name').text()).toEqual("Neil")
      expect($('li.author h4 .author-last-name').text()).toEqual("Bohr")
      expect($('li.author h4.author-email').text()).toEqual("neil@example.com")
      expect($('li.author h4.author-affiliation').text()).toEqual("Universitat")
