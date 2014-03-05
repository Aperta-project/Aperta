describe "Columns", ->
  describe "Columns component", ->
    beforeEach ->
      flows = [
        {title: "Flow 1", paperProfile: []},
        {title: "Flow 2", paperProfile: []}
      ]
      @component = Tahi.flowManager.Columns flows: flows
      @component.state = flows: flows

    describe "#removeFlow", ->
      it "removes the flow with the specified title from the flows collection", ->
        spyOn(@component, 'setState')
        @component.removeFlow 0
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
    describe "#render", ->
      context "when this is a flow manager column (has paperProfiles)", ->
        beforeEach ->
          @component = Tahi.flowManager.Column title: 'Column Title', paperProfiles: [{}]

        it "renders PaperProfile components", ->
          result = @component.render()
          element = result.props.children[2].props.children.props.children[0]
          expect(element.props.children.constructor).toEqual Tahi.flowManager.PaperProfile.componentConstructor

        it "includes remove button", ->
          result = @component.render()
          element = result.props.children[1]
          expect(element.props.className).toContain 'remove-column'

    describe "#remove", ->
      it "removes the current column", ->
        onRemove = jasmine.createSpy 'onRemove'
        component = Tahi.flowManager.Column index: 1, title: 'Flow Title', paperProfiles: [], onRemove: onRemove
        component.remove()
        expect(onRemove).toHaveBeenCalledWith 1
