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
            <textarea></textarea>
          </form>
          <form id="regular-form" class="js-submit-on-change">
            <select>
              <option selected="true" value="1">Option 1</option>
              <option value="2">Option 2</option>
            </select>
            <input type="checkbox" value="1" />
            <textarea></textarea>
          </form>
        """
        $('#jasmine_content').html html

      it "configures submit on change for inputs in remote forms", ->
        spyOn Tahi, 'setupSubmitOnChange'
        form = $('#remote-form')
        fields = $('select, input[type="checkbox"], textarea', form)

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
          <header>
            <h2></h2>
            <a href="#" class="close-overlay">Close</a>
          </header>
          <main></main>
          <footer>
            <div class="content"></div>
          </footer>
        </div>
        <div id="planes-content" style="display: none"><div class="content">Hello</div></div>
        <div id="planes" data-overlay-name="planes" data-overlay-title="It's a plane!" data-paper-id='123' data-task-id='456' data-task-completed="true">Show overlay</div>
      """

    it "moves given div content inside overlay-content", ->
      expected_html = $('#planes-content').html()
      Tahi.displayOverlay($('#planes'))
      expect($('#overlay main').html()).toEqual expected_html
      expect($('#planes-content')).toBeEmpty()

    it "sets the overlay title", ->
      Tahi.displayOverlay($('#planes'))
      expect($('#overlay header h2').text()).toEqual "It's a plane!"

    it "shows the overlay div", ->
      Tahi.displayOverlay($('#planes'))
      expect($('#overlay')).toBeVisible()

    context "when there is a task id data attribute", ->
      it "adds form in footer", ->
        Tahi.displayOverlay($('#planes'))
        expect($('#overlay footer .content form').attr('action')).toEqual('/papers/123/tasks/456')

      it "sets the form up to submit on change", ->
        spyOn Tahi, 'setupSubmitOnChange'
        Tahi.displayOverlay($('#planes'))

        form = $('#complete_task_456')
        field = $('input[type="checkbox"]', form)

        expect(Tahi.setupSubmitOnChange.calls.count()).toEqual 1
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(form.is(args[0])).toEqual true
        expect(args[1].is(field)).toEqual true, "Expected second argument to be #{field}"

      context "when the task is already completed", ->
        it "checks the checkbox", ->
          Tahi.displayOverlay($('#planes'))
          expect($('#overlay footer .content input[type="checkbox"]:checked').length).toEqual 1

      context "when the task is not completed", ->
        beforeEach ->
          $('#jasmine_content').html """
            <div id="overlay" style="display: none">
              <footer>
                <div class="content"></div>
              </footer>
            </div>
            <div id="planes-content" style="display: none"><div class="content">Hello</div></div>
            <div id="planes" data-overlay-name="planes" data-overlay-title="It's a plane!" data-paper-id='123' data-task-id='456' data-task-completed="false">Show overlay</div>
          """

        it "does not check the checkbox", ->
          Tahi.displayOverlay($('#planes'))
          expect($('#overlay footer .content input[type="checkbox"]:checked').length).toEqual 0

    context "when there is no task id data attribute", ->
      beforeEach ->
        $('#jasmine_content').html """
          <div id="overlay" style="display: none">
            <footer>
              <div class="content"></div>
            </footer>
          </div>
          <div id="planes" data-overlay-name="planes" data-overlay-title="It's a plane!" data-paper-id='123'>Show overlay</div>
        """

      it "doesn't add the form in the footer", ->
        Tahi.displayOverlay($('#planes'))
        expect($('#overlay footer .content form').length).toEqual 0

    describe "when the overlay is dismissed", ->
      it "moves back the overlay content to its original container", ->
        Tahi.displayOverlay($('#planes'))
        expected_html = $('#overlay main').html()
        $('.close-overlay').click()
        expect($('#planes-content').html()).toEqual expected_html
        expect($('#overlay main')).toBeEmpty()

      it "clears the overlay title", ->
        Tahi.displayOverlay($('#planes'))
        expect($('#overlay header h2').text()).not.toEqual ""
        $('.close-overlay').click()
        expect($('#overlay header h2').text()).toEqual ""

      it "clears the overlay footer content", ->
        Tahi.displayOverlay($('#planes'))
        expect($('#overlay footer .content').children().length).toBeGreaterThan 0
        $('.close-overlay').click()
        expect($('#overlay footer .content').children().length).toEqual 0

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

      context "when there is a completed checkbox", ->
        beforeEach ->
          $('#jasmine_content').html """
            <div id="overlay" style="display: none">
              <footer>
                <div class="content"></div>
                <a href="#" class="close-overlay">Close</a>
              </footer>
            </div>
            <div id="planes-content" style="display: none"><div class="content">Hello</div></div>
            <div id="planes" data-overlay-name="planes" data-overlay-title="It's a plane!" data-paper-id='123' data-task-id='456' data-task-completed="false">Show overlay</div>
          """

        it "changes the attribute data-task-completed attributed to the checkbox's value", ->
          expect($('#planes').data('task-completed')).toEqual false
          Tahi.displayOverlay $('#planes')
          $('#overlay footer .content form input[type="checkbox"]').click()
          $('.close-overlay').click()
          expect($('#planes').data('task-completed')).toEqual true

          Tahi.displayOverlay $('#planes')
          $('#overlay footer .content form input[type="checkbox"]').click()
          $('.close-overlay').click()
          expect($('#planes').data('task-completed')).toEqual false
