describe "PaperAdmin Card", ->
  describe "Overlay", ->
    describe "#admins", ->
      context "when we have admins in props", ->
        it "returns a list of admins including placeholder", ->
          component = Tahi.overlays.paperAdmin.Overlay
            admins: [[1, 'one']]
          expect(component.admins()).toEqual [[null, 'Please select admin'], [1, 'one']]

      context "when props admins is falsy", ->
        it "returns an empty list", ->
          component = Tahi.overlays.paperAdmin.Overlay
            admins: undefined
          expect(component.admins()).toEqual []

    describe "#componentDidMount", ->
      it "sets up submit on change for the form", ->
        spyOn Tahi, 'setupSubmitOnChange'
        component = Tahi.overlays.paperAdmin.Overlay()
        html = $('<main><form><select /></form></main>')[0]
        component.componentDidMount html
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $('form', html)[0]
        expect(args[1][0]).toEqual $('select', html)[0]
