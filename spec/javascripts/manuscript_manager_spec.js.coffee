describe "Manuscript Manager", ->
  describe "Columns component", ->
    beforeEach ->
      flows = [
        {title: "Flow 1"},
        {title: "Flow 2"}
      ]
      @component = Tahi.manuscriptManager.Columns flows: flows
      @component.state = flows: flows

  describe "Column component", ->
    describe "#render", ->
      context "when this is a manuscript manager column (has tasks)", ->
        beforeEach ->
          @component = Tahi.manuscriptManager.Column title: 'Column Title', tasks: [{}]

        it "renders Card components", ->
          result = @component.render()
          element = result.props.children[2].props.children.props.children[0]
          expect(element.props.children.constructor).toEqual Tahi.manuscriptManager.Card.componentConstructor
