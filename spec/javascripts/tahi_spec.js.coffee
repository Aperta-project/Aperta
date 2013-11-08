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
          </form>
          <form id="regular-form" class="js-submit-on-change">
            <select>
              <option selected="true" value="1">Option 1</option>
              <option value="2">Option 2</option>
            </select>
          </form>
        """
        $('#jasmine_content').html html

      it "configures submit on change for remote forms and its select fields", ->
        spyOn Tahi, 'setupSubmitOnChange'
        form = $('#remote-form')
        selectFields = $('select', form)

        Tahi.init()

        expect(Tahi.setupSubmitOnChange.calls.count()).toEqual 1
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual form[0]
        expect(args[1][0]).toEqual selectFields[0]

  describe "#setupSubmitOnChange", ->
    it "triggers 'submit.rails' event on the form when an element's change event is called", ->
      form = $('<form>')
      element = $('<input>')

      spyOn form, 'trigger'
      Tahi.setupSubmitOnChange form, element

      element.trigger 'change'
      expect(form.trigger).toHaveBeenCalledWith 'submit.rails'
