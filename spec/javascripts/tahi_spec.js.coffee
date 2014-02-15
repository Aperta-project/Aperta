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
            <input type="radio" value="1" />
            <textarea></textarea>
          </form>
          <form id="regular-form" class="js-submit-on-change">
            <select>
              <option selected="true" value="1">Option 1</option>
              <option value="2">Option 2</option>
            </select>
            <input type="checkbox" value="1" />
            <input type="radio" value="1" />
            <textarea></textarea>
          </form>
        """
        $('#jasmine_content').html html

      beforeEach ->
        spyOn Tahi.papers, 'init'
        spyOn Tahi.overlay, 'init'
        spyOn Tahi.overlays.newCard, 'init'

      it "configures submit on change for inputs in remote forms", ->
        spyOn Tahi, 'setupSubmitOnChange'
        form = $('#remote-form')
        fields = $('select, input[type="checkbox"], input[type="radio"], textarea', form)

        Tahi.init()

        expect(Tahi.setupSubmitOnChange.calls.count()).toEqual 1
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(form.is(args[0])).toEqual true
        for field in fields
          expect(args[1].is(field)).toEqual true, "Expected second argument to include #{field}"

      it "invokes init on other modules and overlays", ->
        Tahi.init()
        expect(Tahi.papers.init).toHaveBeenCalled()
        expect(Tahi.overlay.init).toHaveBeenCalled()
        expect(Tahi.overlays.newCard.init).toHaveBeenCalled()

  describe "#initChosen", ->
    it "calls chosen on elements with chosen-select class", ->
      spyOn $.fn, "chosen"
      Tahi.initChosen()
      expect($.fn.chosen).toHaveBeenCalled()

  describe "#setupSubmitOnChange", ->
    beforeEach ->
      @form = $('<form>')
      @element = $('<input>')

      spyOn @form, 'trigger'
      spyOn @form, 'on'

    it "triggers 'submit.rails' event on the form when an element's change event is called", ->
      Tahi.setupSubmitOnChange @form, @element

      @element.trigger 'change'
      expect(@form.trigger).toHaveBeenCalledWith 'submit.rails'

    context "when a success callback is provided", ->
      it "assigns the callback as a handler for ajax:success events", ->
        callback = jasmine.createSpy 'success'
        Tahi.setupSubmitOnChange @form, @element, success: callback
        expect(@form.on).toHaveBeenCalledWith 'ajax:success', callback
