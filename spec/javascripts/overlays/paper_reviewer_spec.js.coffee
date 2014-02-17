describe "PaperReviewer Card", ->
  describe "Overlay", ->
    describe "#componentDidMount", ->
      it "sets up submit on change for the form", ->
        spyOn Tahi, 'setupSubmitOnChange'
        component = Tahi.overlays.paperReviewer.Overlay()
        html = $('<main><form><select /></form></main>')[0]
        component.componentDidMount html
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $('form', html)[0]
        expect(args[1][0]).toEqual $('select', html)[0]
