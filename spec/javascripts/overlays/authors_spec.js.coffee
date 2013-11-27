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
      Tahi.overlays.authors.init()
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
      Tahi.overlays.authors.init()
      expect($('li.author').length).toEqual(0)
      Tahi.overlays.authors.appendAuthorForm()
      expect($('li.author').length).toEqual(1)
      expect($('li.author').text().trim()).toEqual "This is a new author"

    it "binds #htmlify to the submit button", ->
      spyOn Tahi.overlays.authors, 'htmlify'
      Tahi.overlays.authors.init()
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
