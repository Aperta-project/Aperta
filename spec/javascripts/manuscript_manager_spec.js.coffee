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
          @addFn = -> console.log 'Arbitrary Function'
          component = Tahi.manuscriptManager.Column title: 'Column Title', tasks: [{}], addFunction: @addFn
          @children = component.render().props.children

        it "renders Card components", ->
          element = @children[2].props.children.props.children[0]
          expect(element.props.children.constructor).toEqual Tahi.manuscriptManager.Card.componentConstructor

        it "passes its addFunction through to the ColumnAppender", ->
          expect(@children[0].props.addFunction).toEqual @addFn

  describe "ColumnAppender component", ->
    describe "#render", ->
      beforeEach ->
        task =
          cardName: "upload-manuscript"
          taskId: 1
          taskPath: "/papers/1/tasks/1"
        @component = Tahi.manuscriptManager.ColumnAppender task: task
        @result = @component.render()

  describe "Card component", ->
    describe "#render", ->
      beforeEach ->
        task =
          cardName: "upload-manuscript"
          taskId: 1
          taskPath: "/papers/1/tasks/1"
        @component = Tahi.manuscriptManager.Card task: task
        @result = @component.render()

      context "the anchor tag", ->
        beforeEach ->
          @cardAnchor = @result.props.children[0].props

        it "rendering", ->
          expect(@cardAnchor.className).toEqual "card"
          expect(@cardAnchor['data-card-name']).toEqual "upload-manuscript"
          expect(@cardAnchor['data-task-id']).toEqual 1
          expect(@cardAnchor['data-task-path']).toEqual "/papers/1/tasks/1"

        it "child glyphicon", ->
          glyphOk = @cardAnchor.children[0]
          expect(glyphOk.props.className.match("glyphicon glyphicon-ok")).toBeTruthy()


      context "the card delete span", ->
        beforeEach ->
          @deleteSpan = @result.props.children[1].props

        it "renders the Cards", ->
          expect(@deleteSpan.className.match("glyphicon glyphicon-remove-circle")).toBeTruthy()
          expect(@deleteSpan['data-toggle']).toEqual "tooltip"
          expect(@deleteSpan['title']).toEqual "Delete Card"
          expect(@deleteSpan.onClick).toEqual Tahi.manuscriptManager.Card.originalSpec.destroyCard
