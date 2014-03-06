describe "Reviewer Report Card", ->
  describe "Overlay", ->
    describe "#componentDidMount", ->
      it "sets up submit on change for the form", ->
        spyOn Tahi, 'setupSubmitOnChange'
        component = Tahi.overlays.reviewerReport.Overlay()
        html = $('<main><form><textarea /></form></main>')[0]
        spyOn(component, 'getDOMNode').and.returnValue(html)
        component.componentDidMount()
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $('form', html)[0]
        expect(args[1][0]).toEqual $('textarea', html)[0]
