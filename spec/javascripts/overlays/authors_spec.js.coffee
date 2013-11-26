beforeEach ->
  $('#jasmine_content').empty()

describe "Tahi.overlays.authors", ->
  beforeEach ->
    $('#jasmine_content').html """
      <ul class="authors">
      </ul>
      <a href="#" id="add-author">Add new</a>
      <div id="author-form-template">
        <b>This is a new <i>author</i></b>
      </div>
    """

  describe "#init", ->
    it "invokes #appendAuthorForm on 'Add new' click", ->
      spyOn Tahi.overlays.authors, 'appendAuthorForm'
      Tahi.overlays.authors.init()
      $('#add-author').click()
      expect(Tahi.overlays.authors.appendAuthorForm).toHaveBeenCalled()

  describe "#appendAuthorForm", ->
    it "adds a new form row", ->
      Tahi.overlays.authors.init()
      expect($('li.author').length).toEqual(0)
      Tahi.overlays.authors.appendAuthorForm()
      expect($('li.author').length).toEqual(1)
      expect($('li.author').html().trim()).toEqual "<b>This is a new <i>author</i></b>"
