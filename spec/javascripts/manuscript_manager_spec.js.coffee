describe "Manuscript Manager", ->
  describe "Column component", ->
    describe "#render", ->
      context "when this is a manuscript manager column (has tasks)", ->
        beforeEach ->
          @addFn = -> console.log 'Arbitrary Function'
          component = Tahi.manuscriptManager.Column title: 'Column Title', tasks: [{}], addFunction: @addFn
          @children = component.render().props.children

        it "renders Card components", ->
          element = @children[2].props.children.props.children[0]
          expect(element.props.children.constructor).toEqual Tahi.columnComponents.Card.componentConstructor

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
        @component = Tahi.columnComponents.Card task: task
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
          expect(@deleteSpan.onClick).toEqual Tahi.columnComponents.Card.originalSpec.destroyCard

describe "Tahi.manuscriptManager", ->
  describe "Columns component", ->
    beforeEach ->
      @component = Tahi.manuscriptManager.Columns()
      @component.state =
        flows: [
          {id: 321, title: "Hello world", tasks: [{taskId: 1}, {taskId: 2}, {taskId: 3}]}
        ]

      html = """
        <div id="destination" data-phase-id="321">
          <h2>Hello world</h2>
        </div>
      """
      $('#jasmine_content').html html

    describe "#pushDraggedTask", ->
      beforeEach ->
        task = {taskId: 10}
        @destinationFlow = @component.pushDraggedTask(task, $('#destination')[0])

      it "returns the destinationFlow", ->
        expect(@destinationFlow.title).toEqual 'Hello world'

      it "pushes the dragged task into the destination flow", ->
        expect(@destinationFlow.tasks.length).toEqual 4

    describe "#popDraggedTask", ->
      it "removes the task from the flow", ->
        task = @component.popDraggedTask(1)
        expect(@component.state.flows[0].tasks.length).toEqual(2)

      it "returns the task matching the flow", ->
        task = @component.popDraggedTask(1)
        expect(task).toEqual({taskId: 1})

    describe "#syncTask", ->
      it "sends an ajax request with task and phase id", ->
        spyOn($, 'ajax')
        @component.syncTask({taskId: 1, paperId: 4}, @component.state.flows[0])
        expect($.ajax).toHaveBeenCalledWith
          url: "/papers/4/tasks/1"
          method: 'POST'
          data:
            _method: 'PUT'
            task:
              id: 1
              phase_id: 321
