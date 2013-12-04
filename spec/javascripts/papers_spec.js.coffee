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
        $('#jasmine_content').html """<div id="authors"></div>"""
        spyOn Tahi.papers, 'bindCloseToUpdateAuthors'
        Tahi.papers.init()
        $('#authors').click()
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
        <div id="authors">
          Some text that's here on page load
        </div>
      """

    it "processes the authors array and puts it in the #authors div", ->
      spyOn(Tahi.papers, 'authors').and.returnValue [
        { first_name: "Neils", last_name: "Bohr", affiliation: "University of Copenhagen", email: "neils@example.org" },
        { first_name: "Nikola", last_name: "Tesla", affiliation: "Wardenclyffe", email: "" }
      ]
      Tahi.papers.updateAuthors()
      expect($('#authors').text().trim()).toEqual('Neils Bohr, Nikola Tesla')

    context "when there are no authors", ->
      it "puts a 'click here' message in the authors div", ->
        spyOn(Tahi.papers, 'authors').and.returnValue []
        Tahi.papers.updateAuthors()
        expect($('#authors').text().trim()).toEqual('Click here to add authors')


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
        <div class="container">
          <div id='control-bar-container' style="height: 246px;"><h1>This is the header</h1></div>
          <main>
            <div id="toolbar">Toolbar goes here</div>
            <article>Main text</article>
            <aside>Sidebar</aside>
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
      expect(objects).toContain $('aside')[0], "Expected <aside> to be fixed"

    describe "right bar (aside)", ->
      it "has its top set to 0 on unfixed", ->
        aside = $("aside")[0]
        aside.style.top = '100px'
        expect(aside.style.top).toEqual '100px'

        asideCall = null
        for call in $.fn.scrollToFixed.calls.all()
          if call.object[0] == aside
            asideCall = call

        asideCall.args[0].unfixed.call aside

        expect(aside.style.top).toEqual '0px'
