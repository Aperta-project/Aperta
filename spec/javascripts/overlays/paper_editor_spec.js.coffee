describe "StandardsPaperEditor Card", ->
  describe "Overlay", ->
    describe "#editors", ->
      context "when we have editors in props", ->
        it "returns a list of editors including placeholder", ->
          component = Tahi.overlays.standardsPaperEditor.Overlay
            editors: [{id: 1, full_name: 'one'}]
          expect(component.editors()).toEqual [[null, 'Please select editor'], [1, 'one']]

      context "when props editors is falsy", ->
        it "returns an empty list", ->
          component = Tahi.overlays.standardsPaperEditor.Overlay
            editors: undefined
          expect(component.editors()).toEqual []
