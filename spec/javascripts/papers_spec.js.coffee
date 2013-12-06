beforeEach ->
  $('#jasmine_content').empty()

describe "Tahi.papers", ->
  describe "#init", ->
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

      it "binds #bindCloseToUpdateAuthors to #authors click", ->
        $('#jasmine_content').html """<div id="paper-authors" class="editable"></div>"""
        spyOn Tahi.papers, 'bindCloseToUpdateAuthors'
        Tahi.papers.init()
        $('#paper-authors').click()
        expect(Tahi.papers.bindCloseToUpdateAuthors).toHaveBeenCalled()

      it "runs #updateAuthors", ->
        spyOn Tahi.papers, 'updateAuthors'
        Tahi.papers.init()
        expect(Tahi.papers.updateAuthors).toHaveBeenCalled()

  describe "#bindCloseToUpdateAuthors", ->
    context "when clicked", ->
      it "binds click event to update authors in the #authors div", ->
        $('#jasmine_content').html """
          <a class="close-overlay"></a>
        """
        spyOn(Tahi.papers, 'updateAuthors')
        Tahi.papers.bindCloseToUpdateAuthors()
        $('.close-overlay').click()
        expect(Tahi.papers.updateAuthors).toHaveBeenCalled()

  describe "#updateAuthors", ->
    beforeEach ->
      $('#jasmine_content').html """
        <div id="paper-authors" class="editable">
          Some text that's here on page load
        </div>
      """

    it "processes the authors array and puts it in the #authors div", ->
      spyOn(Tahi.papers, 'authors').and.returnValue [
        { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
        { first_name: "Nikola", last_name: "Tesla", affiliation: "Wardenclyffe", email: "" }
      ]
      Tahi.papers.updateAuthors()
      expect($('#paper-authors').text().trim()).toEqual('Neils Bohr, Nikola Tesla')

    context "when there are no authors", ->
      it "puts a 'click here' message in the authors div", ->
        spyOn(Tahi.papers, 'authors').and.returnValue []
        Tahi.papers.updateAuthors()
        expect($('#paper-authors').text().trim()).toEqual('Click here to add authors')


  describe "#authors", ->
    it "returns an array of objects describing authors", ->
      $('#jasmine_content').html """
        <ul class="authors">
          <li class="author">
            <h4>
              <div class="author-first-name">
                Neils
              </div>
              <div class="author-last-name">             Bohr   </div>
            </h4>
            <div class="author-affiliation">University of Copenhagen</div>
            <div class="author-email">neils@example.org</div>
          </li>
          <li class="author">
            <h4>
              <div class="author-first-name">Nikola</div>
              <div class="author-last-name">Tesla</div>
            </h4>
            <div class="author-affiliation">Wardenclyffe</div>
            <div class="author-email"></div>
          </li>
          <li class="author">
            <h4>
            </h4>
          </li>
        </ul>
      """
      authors = Tahi.papers.authors()
      expect(authors).toEqual [
        { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
        { first_name: "Nikola", last_name: "Tesla", affiliation: "Wardenclyffe", email: "" }
      ]

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

      Tahi.papers.titleEditable = jasmine.createSpyObj('titleEditable', ['getText'])
      Tahi.papers.titleEditable.getText.and.returnValue('Melting rates of soy-milk based frozen desserts')

      Tahi.papers.bodyEditable = jasmine.createSpyObj('bodyEditable', ['getText'])
      Tahi.papers.bodyEditable.getText.and.returnValue('This is the melted body of the really melted frozen dessert.')

      Tahi.papers.abstractEditable = jasmine.createSpyObj('abstractEditable', ['getText'])
      Tahi.papers.abstractEditable.getText.and.returnValue('ME ME ABSTRACT ABSTRACT')

      event = jasmine.createSpyObj('event', ['target', 'preventDefault'])
      event.target.and.returnValue
        attr: (key) ->
          { href: '/path/to/resource' }[key]
      Tahi.papers.savePaper(event)

      expect($.ajax).toHaveBeenCalledWith
        url: '/path/to/resource'
        method: 'POST'
        data:
          _method: 'patch'
          paper:
            title: 'Melting rates of soy-milk based frozen desserts'
            body: 'This is the melted body of the really melted frozen dessert.'
            abstract: 'ME ME ABSTRACT ABSTRACT'
            short_title: ''
            authors: '[]'
