describe "Flow Manager", ->
  describe "Flow Manager component", ->
    describe "#removeFlow", ->
      it "removes the flow with the specified title from the flows collection", ->
        flows = [
          {title: "Flow 1", paperProfile: []},
          {title: "Flow 2", paperProfile: []}
        ]
        component = Tahi.flowManager.FlowManager flows: flows
        component.state = flows: flows
        spyOn(component, 'setState')
        component.removeFlow 'Flow 1'
        expect(component.setState).toHaveBeenCalledWith flows: [{title: "Flow 2", paperProfile: []}]

  describe "Flow component", ->
    describe "#remove", ->
      it "removes the current column", ->
        onRemove = jasmine.createSpy 'onRemove'
        component = Tahi.flowManager.Flow title: 'Flow Title', paperProfiles: [], onRemove: onRemove
        component.remove()
        expect(onRemove).toHaveBeenCalledWith 'Flow Title'
