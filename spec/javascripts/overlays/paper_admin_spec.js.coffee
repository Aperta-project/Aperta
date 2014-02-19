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
