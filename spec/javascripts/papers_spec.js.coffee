beforeEach ->
  $('#jasmine_content').empty()

describe "papers", ->
  describe "Add authors link", ->
    it "adds a new form row", ->
      $('#jasmine_content').html """
        <ul class="authors">
        </ul>
        <a href="#" id="add_author">Add author</a>
      """
      Tahi.papers.init()
      expect($('li.author').length).toEqual(0)
      $('#add_author').click()
      expect($('li.author').length).toEqual(1)
