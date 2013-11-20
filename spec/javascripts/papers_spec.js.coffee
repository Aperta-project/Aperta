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

  describe "#authors", ->
    it "returns an array of objects describing authors", ->
      $('#jasmine_content').html """
        <ul class="authors">
          <li class="author">
            <div class="author-first-name">Neils</div>
            <div class="author-last-name">Bohr</div>
            <div class="author-affiliation">University of Copenhagen</div>
            <div class="author-email">neils@example.org</div>
          </li>
          <li class="author">
            <div class="author-first-name">Nikola</div>
            <div class="author-last-name">Tesla</div>
            <div class="author-affiliation">Wardenclyffe</div>
            <div class="author-email"></div>
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
        <header style="height: 246px;"><h1>This is the header</h1></header>
        <main>
          <div id="toolbar">Toolbar goes here</div>
          <article>Main text</article>
          <aside>Sidebar</aside>
        </main>
      """

      spyOn($.fn, 'scrollToFixed')
      Tahi.papers.fixArticleControls()

    it "fixes the header", ->
      expect($.fn.scrollToFixed).toHaveBeenCalled()
      objects = $.fn.scrollToFixed.calls.all().map (c)-> c.object[0]
      expect(objects).toContain $('header')[0], "Expected <header> to be fixed"

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
        aside = $("aside")
        aside.css('top', '100px')

        asideCall = null
        for call in $.fn.scrollToFixed.calls.all()
          if call.object[0] == aside[0]
            asideCall = call

        asideCall.args[0].unfixed.call aside

        expect(aside.css('top')).toEqual '0px'
