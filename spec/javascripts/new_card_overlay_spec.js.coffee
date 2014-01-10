describe "New Card Overlay", ->
  describe "NewCardOverlay component", ->
    describe "#render", ->
      it "renders stuff", ->
        ReactTestUtils = React.addons.ReactTestUtils
        spyOn React, 'renderComponent'
        event = jasmine.createSpyObj 'event', ['preventDefault']
        Tahi.newCardOverlay(event)
        component = Tahi.components.NewCardOverlay()
        result = component.render()
        debugger
