describe "Columns", ->
  describe "Columns component", ->
    beforeEach ->
      flows = [
        {title: "Flow 1", paperProfile: []},
        {title: "Flow 2", paperProfile: []}
      ]
      @component = Tahi.columns.Columns flows: flows
      @component.state = flows: flows

    describe "#removeFlow", ->
      it "removes the flow with the specified title from the flows collection", ->
        spyOn(@component, 'setState')
        @component.removeFlow 'Flow 1'
        expect(@component.setState).toHaveBeenCalledWith
          flows: [{title: "Flow 2", paperProfile: []}],
          @component.saveFlows

    describe "#saveFlows", ->
      it "sets the user's flows setting", ->
        spyOn $, 'ajax'
        @component.saveFlows()
        expect($.ajax).toHaveBeenCalledWith(
          jasmine.objectContaining
            url: 'user_settings'
            type: 'post'
            data:
              _method: 'PATCH'
              user_settings:
                flows: ['Flow 1', 'Flow 2']
        )

  describe "Column component", ->
    describe "#remove", ->
      it "removes the current column", ->
        onRemove = jasmine.createSpy 'onRemove'
        component = Tahi.columns.Column title: 'Flow Title', paperProfiles: [], onRemove: onRemove
        component.remove()
        expect(onRemove).toHaveBeenCalledWith 'Flow Title'
