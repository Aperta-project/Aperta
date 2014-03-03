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

  describe "Card component", ->
    describe "#render", ->
      beforeEach ->
        task =
          cardName: "upload-manuscript"
          taskId: 1
          taskPath: "/papers/1/tasks/1"
        @component = Tahi.manuscriptManager.Card task: task

      context "the anchor tag", ->
        beforeEach ->
          result = @component.render()
          @cardAnchor = result.props.children[0].props

        it "rendering", ->
          expect(@cardAnchor.className).toEqual "card"
          expect(@cardAnchor['data-card-name']).toEqual "upload-manuscript"
          expect(@cardAnchor['data-task-id']).toEqual 1
          expect(@cardAnchor['data-task-path']).toEqual "/papers/1/tasks/1"

        it "child glyphicon", ->
          glyphOk = @cardAnchor.children[0]
          expect(glyphOk.props.className.match("glyphicon glyphicon-ok")).toBeTruthy()
