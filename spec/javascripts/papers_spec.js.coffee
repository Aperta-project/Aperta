beforeEach ->
  $('#jasmine_content').empty()

describe "papers", ->
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

describe "Tahi.papers", ->
  describe "authors", ->
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
