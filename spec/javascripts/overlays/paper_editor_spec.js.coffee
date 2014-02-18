describe "PaperEditor Card", ->
  describe "Overlay", ->
    describe "#editors", ->
      context "when we have editors in props", ->
        it "returns a list of editors including placeholder", ->
          component = Tahi.overlays.paperEditor.Overlay
            editors: [[1, 'one']]
          expect(component.editors()).toEqual [[null, 'Please select editor'], [1, 'one']]

      context "when props editors is falsy", ->
        it "returns an empty list", ->
          component = Tahi.overlays.paperEditor.Overlay
            editors: undefined
          expect(component.editors()).toEqual []

    describe "#componentDidMount", ->
      it "sets up submit on change for the form", ->
        spyOn Tahi, 'setupSubmitOnChange'
        component = Tahi.overlays.paperEditor.Overlay()
        html = $('<main><form><select /></form></main>')[0]
        component.componentDidMount html
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $('form', html)[0]
        expect(args[1][0]).toEqual $('select', html)[0]
