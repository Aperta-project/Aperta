beforeEach ->
  $('#jasmine_content').empty()

describe "Tahi.RichEditableElement", ->
  beforeEach ->
    element = $('<div id="article_body_editable" contenteditable="true" placeholder="Article placeholder text">')
    @richEditableElement = new Tahi.RichEditableElement(element[0])

  describe "constructor", ->
    it "initializes CKEDITOR and stores the instance", ->
      expect(CKEDITOR.instances.article_body_editable).toBeDefined()
      expect(CKEDITOR.instances.article_body_editable).toEqual @richEditableElement.instance

    it "sets the element's content to the placeholder", ->
      expect(@richEditableElement.instance.getData()).toEqual 'Article placeholder text'

    it "has a placeholder text", ->
      expect(@richEditableElement.placeholderText).toEqual 'Article placeholder text'

    describe "events", ->
      it "clears the placeholder on focus", ->
        spyOn @richEditableElement, 'clearPlaceholder'
        @richEditableElement.instance.fire 'focus'
        expect(@richEditableElement.clearPlaceholder).toHaveBeenCalled()

      it "sets the placeholder on blur", ->
        spyOn @richEditableElement, 'setPlaceholder'
        @richEditableElement.instance.fire 'blur'
        expect(@richEditableElement.setPlaceholder).toHaveBeenCalled()

  describe "#getText", ->
    context "when the element contains placeholder text", ->
      it "returns empty text", ->
        element = $('<div id="article_body_editable" contenteditable="true" placeholder="Article placeholder text">Article placeholder text</div>')
        @richEditableElement = new Tahi.RichEditableElement(element[0])
        expect(@richEditableElement.getText()).toEqual('')

    context "when the element doesn't contain placeholder text", ->
      it "returns the text", ->
        element = $('<div id="article_body_editable" contenteditable="true" placeholder="Article placeholder text">Frappuccino is nice but I think <strong>I am starting to get over it</strong>.</div>')
        @richEditableElement = new Tahi.RichEditableElement(element[0])
        expect(@richEditableElement.getText()).toEqual('Frappuccino is nice but I think <strong>I am starting to get over it</strong>.')

    context "when the element is empty", ->
      it "returns empty text", ->
        element = $('<div id="article_body_editable" contenteditable="true" placeholder="Article placeholder text"></div>')
        @richEditableElement = new Tahi.RichEditableElement(element[0])
        expect(@richEditableElement.getText()).toEqual('')

  describe "#setPlaceholder", ->
    context "when the element is empty", ->
      it "sets the content of the element with the placeholder", ->
        @richEditableElement.instance.setData('')
        @richEditableElement.setPlaceholder()
        expect(@richEditableElement.instance.getData()).toEqual('Article placeholder text')
        expect(@richEditableElement.element.classList.contains('placeholder')).toBeTruthy()

    context "when the element's content is that of placeholder's", ->
      it "sets the content of the element with the placeholder", ->
        @richEditableElement.instance.setData('Article placeholder text')
        @richEditableElement.setPlaceholder()
        expect(@richEditableElement.element.classList.contains('placeholder')).toBeTruthy()
        expect(@richEditableElement.instance.getData()).toEqual('Article placeholder text')

    context "when element has content", ->
      it "doesn't set the placeholder", ->
        @richEditableElement.instance.setData('Lorem Ipsum Rocks!')
        @richEditableElement.element.classList.remove('placeholder')
        @richEditableElement.setPlaceholder()
        expect(@richEditableElement.element.classList.contains('placeholder')).toBeFalsy()
        expect(@richEditableElement.instance.getData()).toEqual('Lorem Ipsum Rocks!')

  describe "#clearPlaceholder", ->
    context "when the content is the placeholder text", ->
      it "clears the placeholder", ->
        @richEditableElement.instance.setData('Article placeholder text')
        @richEditableElement.element.classList.add('placeholder')
        @richEditableElement.clearPlaceholder()
        expect(@richEditableElement.element.classList.contains('placeholder')).toBeFalsy()
        expect(@richEditableElement.instance.getData()).toEqual('')

    context "when the content is not the placeholder text", ->
      it "does not modify the element", ->
        @richEditableElement.instance.setData('Lorem Ipsum Rocks!')
        @richEditableElement.clearPlaceholder()
        expect(@richEditableElement.instance.getData()).toEqual('Lorem Ipsum Rocks!')
