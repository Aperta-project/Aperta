beforeEach ->
  $('#jasmine_content').empty()

describe "Tahi.papers", ->
  describe "#init", ->
    beforeEach ->
      spyOn Tahi.papers, 'initAuthors'

    describe "Add authors link", ->
      it "adds a new form row", ->
        $('#jasmine_content').html """
          <ul class="authors">
          </ul>
          <a href="#" id="add_author">Add author</a>
          <div id="author-template">
            <b>This is a new <i>author</i></b>
          </div>
        """
        Tahi.papers.init()
        expect($('li.author').length).toEqual(0)
        $('#add_author').click()
        expect($('li.author').length).toEqual(1)
        expect($('li.author').html().trim()).toEqual "<b>This is a new <i>author</i></b>"

      it "sets up fixed elements during scrolling", ->
        spyOn(Tahi.papers, 'fixArticleControls')
        Tahi.papers.init()
        expect(Tahi.papers.fixArticleControls).toHaveBeenCalled()

      it "runs #initAuthors", ->
        Tahi.papers.init()
        expect(Tahi.papers.initAuthors).toHaveBeenCalled()

  describe "#initAuthors", ->
    beforeEach ->
      spyOn React, 'renderComponent'
      authors = [
        { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
        { first_name: "Nikola", last_name: "Tesla", affiliation: "Wardenclyffe", email: "" }
      ]
      $('#jasmine_content').html """
        <div id='paper-authors' data-authors='#{JSON.stringify(authors)}' />
      """

    it "provides author data to component", ->
      spyOn Tahi.papers.components, 'Authors'
      Tahi.papers.initAuthors()
      expect(Tahi.papers.components.Authors).toHaveBeenCalledWith
        authors: [
          { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
          { first_name: "Nikola", last_name: "Tesla", affiliation: "Wardenclyffe", email: "" }
        ]

    it "assigns authors", ->
      Tahi.papers.initAuthors()
      expect(Tahi.papers.authors).toBeDefined()
      expect(Tahi.papers.authors.constructor).toEqual Tahi.papers.components.Authors.componentConstructor

    it "mounts a component at paper-authors", ->
      Tahi.papers.initAuthors()
      component = Tahi.papers.authors
      expect(React.renderComponent).toHaveBeenCalledWith component, document.getElementById('paper-authors')

    context "when the mount point does not exist", ->
      it "does not attempt to mount the component", ->
        $('#jasmine_content').empty()
        Tahi.papers.initAuthors()
        expect(React.renderComponent).not.toHaveBeenCalled()

  describe "Authors component", ->
    describe "#componentDidMount", ->
      it "sets subscribes to the update_authors topic", (done) ->
        authors = jasmine.createSpy('authors')
        component = Tahi.papers.components.Authors()
        spyOn(component, 'setState')
        component.componentDidMount()
        Tahi.pubsub.publish('update_authors', authors)
        setTimeout (->
          expect(component.setState).toHaveBeenCalledWith
            authors: authors
          done()
        )

    describe "#componentWillUnmount", ->
      it "unsubscribes from the update_authors topic", ->
        component = Tahi.papers.components.Authors()
        component.token = 123
        spyOn(Tahi.pubsub, 'unsubscribe')
        component.componentWillUnmount()
        expect(Tahi.pubsub.unsubscribe).toHaveBeenCalledWith(123)

    describe "#render", ->
      beforeEach ->
        @component = Tahi.papers.components.Authors()
        @component.state ||= {}

      it "contains a comma-separated list of authors' first and last names", ->
        @component.state.authors = [
            { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
            { first_name: "Nikola", last_name: "Tesla", affiliation: "Wardenclyffe", email: "" }
          ]
        result = @component.render()
        expect(result.props.className).toBeUndefined()
        expect(result.props.children).toEqual('Neils Bohr, Nikola Tesla')

      context "when the authors array is empty", ->
        it "renders placeholder text", ->
          @component.state.authors = []
          result = @component.render()
          expect(result.props.className).toEqual 'placeholder'
          expect(result.props.children).toEqual('Click here to add authors')

  describe "#fixArticleControls", ->
    beforeEach ->
      $('#jasmine_content').html """
        <div id="tahi-container">
          <div id='control-bar-container' style="height: 246px;"><h1>This is the header</h1></div>
          <main>
            <div id="toolbar">Toolbar goes here</div>
            <article>Main text</article>
            <aside><div id='right-rail'>Sidebar</div></aside>
          </main>
        </div>
      """

      spyOn($.fn, 'scrollToFixed')
      Tahi.papers.fixArticleControls()

    it "fixes the header", ->
      expect($.fn.scrollToFixed).toHaveBeenCalled()
      objects = $.fn.scrollToFixed.calls.all().map (c)-> c.object[0]
      expect(objects).toContain $('#control-bar-container')[0], "Expected control bar container to be fixed"

    it "fixes the toolbar", ->
      expect($.fn.scrollToFixed).toHaveBeenCalledWith(marginTop: 246)
      objects = $.fn.scrollToFixed.calls.all().map (c)-> c.object[0]
      expect(objects).toContain $('#toolbar')[0], "Expected toolbar to be fixed"

    it "fixes the right bar", ->
      expect($.fn.scrollToFixed).toHaveBeenCalledWith
        marginTop: 246
        unfixed: jasmine.any(Function)
      objects = $.fn.scrollToFixed.calls.all().map (c)-> c.object[0]
      expect(objects).toContain $('#right-rail')[0], "Expected right rail to be fixed"

    describe "right rail", ->
      it "has its top set to 0 on unfixed", ->
        rightRail = $("#right-rail")[0]
        rightRail.style.top = '100px'
        expect(rightRail.style.top).toEqual '100px'

        rightRailCall = null
        for call in $.fn.scrollToFixed.calls.all()
          if call.object[0] == rightRail
            rightRailCall = call

        rightRailCall.args[0].unfixed.call rightRail

        expect(rightRail.style.top).toEqual '0px'

  describe "#savePaper", ->
    it "makes AJAX request", ->
      spyOn($, 'ajax')

      # Tahi.papers.shortTitleEditable = jasmine.createSpyObj('shortTitleEditable', ['getText'])
      # Tahi.papers.shortTitleEditable.getText.and.returnValue('melted-rates')

      Tahi.papers.titleEditable = jasmine.createSpyObj('titleEditable', ['getText'])
      Tahi.papers.titleEditable.getText.and.returnValue('Melting rates of soy-milk based frozen desserts')

      Tahi.papers.bodyEditable = jasmine.createSpyObj('bodyEditable', ['getText'])
      Tahi.papers.bodyEditable.getText.and.returnValue('This is the melted body of the really melted frozen dessert.')

      Tahi.papers.abstractEditable = jasmine.createSpyObj('abstractEditable', ['getText'])
      Tahi.papers.abstractEditable.getText.and.returnValue('ME ME ABSTRACT ABSTRACT')

      Tahi.papers.savePaper('/path/to/resource' )

      expect($.ajax).toHaveBeenCalledWith
        url: '/path/to/resource'
        method: 'POST'
        data:
          _method: 'patch'
          paper:
            title: 'Melting rates of soy-milk based frozen desserts'
            body: 'This is the melted body of the really melted frozen dessert.'
            abstract: 'ME ME ABSTRACT ABSTRACT'
