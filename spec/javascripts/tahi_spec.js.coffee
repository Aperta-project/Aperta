beforeEach ->
  $('#jasmine_content').empty()

describe "tahi", ->
  describe "#init", ->
    describe "js-submit-on-change forms", ->
      beforeEach ->
        html = """
          <form id="remote-form" class="js-submit-on-change" data-remote="true">
            <select>
              <option selected="true" value="1">Option 1</option>
              <option value="2">Option 2</option>
            </select>
            <input type="checkbox" value="1" />
          </form>
          <form id="regular-form" class="js-submit-on-change">
            <select>
              <option selected="true" value="1">Option 1</option>
              <option value="2">Option 2</option>
            </select>
            <input type="checkbox" value="1" />
          </form>
        """
        $('#jasmine_content').html html

      it "configures submit on change for remote forms and its select fields", ->
        spyOn Tahi, 'setupSubmitOnChange'
        form = $('#remote-form')
        fields = $('select, input[type="checkbox"]', form)

        Tahi.init()

        expect(Tahi.setupSubmitOnChange.calls.count()).toEqual 1
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(form.is(args[0])).toEqual true
        for field in fields
          expect(args[1].is(field)).toEqual true, "Expected second argument to include #{field}"

  describe "#setupSubmitOnChange", ->
    it "triggers 'submit.rails' event on the form when an element's change event is called", ->
      form = $('<form>')
      element = $('<input>')

      spyOn form, 'trigger'
      Tahi.setupSubmitOnChange form, element

      element.trigger 'change'
      expect(form.trigger).toHaveBeenCalledWith 'submit.rails'

  describe "initOverlay", ->
    it "binds a click event to the element which opens the overlay", ->
      $('#jasmine_content').html """
        <div id="bar" data-overlay-content-id="foo"></div>
        <div id="foo">Overlay content</div>
      """
      spyOn Tahi, 'displayOverlay'
      element = $('#bar')
      Tahi.initOverlay element[0]
      element.click()
      expect(Tahi.displayOverlay).toHaveBeenCalled()

  describe "displayOverlay", ->
    beforeEach ->
      $('#jasmine_content').html """
        <div id="overlay" style="display: none">
          <a href="#" class="close-overlay">Close</a>
          <main></main>
        </div>
        <div id="planes-content" style="display: none"><div class="content">Hello</div></div>
        <div id="planes" data-overlay-name="planes">Show overlay</div>
      """

    it "moves given div content inside overlay-content", ->
      expected_html = $('#planes-content').html()
      Tahi.displayOverlay($('#planes'))
      expect($('#overlay main').html()).toEqual expected_html
      expect($('#planes-content')).toBeEmpty()

    it "shows the overlay div", ->
      Tahi.displayOverlay($('#planes'))
      expect($('#overlay')).toBeVisible()

    describe "when the overlay is dismissed", ->
      it "moves back the overlay content to its original container", ->
        Tahi.displayOverlay($('#planes'))
        expected_html = $('#overlay main').html()
        $('.close-overlay').click()
        expect($('#planes-content').html()).toEqual expected_html
        expect($('#overlay main')).toBeEmpty()

      it "hides the overlay", ->
        Tahi.displayOverlay($('#planes'))
        $('.close-overlay').click()
        expect($('#overlay')).not.toBeVisible()

      it "unbinds further close button click events", ->
        Tahi.displayOverlay($('#planes'))
        $('.close-overlay').click()
        expect($('#overlay')).not.toBeVisible()
        $('#overlay').show()
        $('.close-overlay').click()
        expect($('#overlay')).toBeVisible()
