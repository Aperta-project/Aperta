beforeEach ->
  $('#jasmine_content').empty()

describe "Tahi.PlaceholderElement", ->
  beforeEach ->
    html = """
      <h1 id="title" contenteditable="true" placeholder="Placeholder for heading"></h1>
    """
    $('#jasmine_content').html(html)
    @placeholderElement = new Tahi.PlaceholderElement(document.getElementById('title'))

  describe "constructor", ->
    it "stores the placeholder text from the element's placeholder attribute", ->
      expect(@placeholderElement.placeholder).toEqual("Placeholder for heading")

    it "sets the element's content to the placeholder", ->
      expect($('#title').text()).toEqual 'Placeholder for heading'

    describe "events", ->
      it "clears the placeholder on focus", ->
        spyOn @placeholderElement, 'clearPlaceholder'
        $('#title').trigger 'focus'
        expect(@placeholderElement.clearPlaceholder).toHaveBeenCalled()

      it "sets the placeholder on blur", ->
        spyOn @placeholderElement, 'setPlaceholder'
        $('#title').trigger 'blur'
        expect(@placeholderElement.setPlaceholder).toHaveBeenCalled()

  describe "#setPlaceholder", ->
    context "when there is no content", ->
      it "places the placeholder text", ->
        $('#title').text('')
        $('#title').removeClass('placeholder')
        @placeholderElement.setPlaceholder()
        expect($('#title').text()).toEqual('Placeholder for heading')
        expect($('#title').hasClass('placeholder')).toBeTruthy()

    context "when there's some content", ->
      it "does not place the placeholder text", ->
        $('#title').text('foo')
        @placeholderElement.setPlaceholder()
        expect($('#title').text()).toEqual('foo')

    context "when there's only whitespace", ->
      it "places the placeholder text", ->
        $('#title').text("    \n \t")
        $('#title').removeClass('placeholder')
        @placeholderElement.setPlaceholder()
        expect($('#title').text()).toEqual('Placeholder for heading')
        expect($('#title').hasClass('placeholder')).toBeTruthy()

  describe "#clearPlaceholder", ->
    context "when there is placeholder text", ->
      it "clears the text", ->
        $('#title').text('Placeholder for heading')
        $('#title').addClass('placeholder')
        @placeholderElement.clearPlaceholder()
        expect($('#title').text()).toEqual('')
        expect($('#title').hasClass('placeholder')).toBeFalsy()

    context "when there is other text", ->
      it "does not clear the text", ->
        $('#title').text('Foo')
        @placeholderElement.clearPlaceholder()
        expect($('#title').text()).toEqual('Foo')
