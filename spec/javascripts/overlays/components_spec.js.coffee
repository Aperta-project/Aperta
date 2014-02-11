describe "Tahi overlay components", ->
  describe "Overlay", ->
    describe "#render", ->
      beforeEach ->
        @onCompletedChangedCallback = jasmine.createSpy 'onCompletedChanged'
        @onOverlayClosedCallback = jasmine.createSpy 'onOverlayClosed'
        @mainContent = React.DOM.main()
        @component = Tahi.overlays.components.Overlay(
          {
            paperTitle: 'A working title'
            paperPath: '/path/to/paper'
            taskPath: '/path/to/task'
            taskCompleted: false
            onOverlayClosed: @onOverlayClosedCallback
            onCompletedChanged: @onCompletedChangedCallback
          },
          @mainContent
        )

      it "renders an overlay header", ->
        header = @component.render().props.children[0]
        OverlayHeader = Tahi.overlays.components.OverlayHeader
        expect(header.constructor).toEqual OverlayHeader.componentConstructor
        expect(header.props.paperTitle).toEqual 'A working title'
        expect(header.props.paperPath).toEqual '/path/to/paper'
        expect(header.props.closeCallback).toEqual @onOverlayClosedCallback

      it "renders an overlay footer, passing it an onCompletedChanged callback", ->
        footer = @component.render().props.children[2]
        OverlayFooter = Tahi.overlays.components.OverlayFooter
        expect(footer.constructor).toEqual OverlayFooter.componentConstructor
        expect(footer.props.checkboxFormAction).toEqual '/path/to/task.json'
        expect(footer.props.taskCompleted).toEqual false
        expect(footer.props.onCompletedChanged).toEqual @onCompletedChangedCallback
        expect(footer.props.closeCallback).toEqual @onOverlayClosedCallback

      it "renders the main content between the header and footer", ->
        mainContent = @component.render().props.children[1]
        expect(mainContent).toEqual @mainContent


  describe "RailsForm", ->
    describe "#render", ->
      beforeEach ->
        @component = Tahi.overlays.components.RailsForm(
          { action: '/form/action' },
          React.DOM.input({type: 'foo'})
        )

      it "renders a form with the specified action", ->
        form = @component.render()
        expect(form.props.action).toEqual '/form/action'

      it "contains a hidden div component", ->
        hiddenDiv = @component.render().props.children[0]
        expect(hiddenDiv.constructor).toEqual Tahi.overlays.components.RailsFormHiddenDiv.componentConstructor

      it "contains provided content", ->
        input = @component.render().props.children[1]
        expect(input.props.type).toEqual 'foo'

  describe "CompletedCheckbox", ->
    beforeEach ->
      @successCallback = jasmine.createSpy 'successCallback'
      @component = Tahi.overlays.components.CompletedCheckbox
        action: '/form/action'
        onSuccess: @successCallback

    describe "#render", ->
      it "generates a form for the task", ->
        # paperId, taskId, taskCompleted
        form = @component.render()
        expect(form.props.action).toEqual '/form/action'

      context "when the task has been completed", ->
        beforeEach -> @component.props.taskCompleted = true

        it "checks the checkbox", ->
          checkbox = @component.render().props.children.props.children[1]
          expect(checkbox.props.defaultChecked).toEqual true

      context "when the task has not been completed", ->
        beforeEach -> @component.props.taskCompleted = false

        it "does not check the checkbox", ->
          checkbox = @component.render().props.children.props.children[1]
          expect(checkbox.props.defaultChecked).toEqual false

    describe "#componentDidMount", ->
      it "sets up submit on change for the check box", ->
        spyOn Tahi, 'setupSubmitOnChange'
        html = $('<form><input type="checkbox" /></form>')[0]
        @component.componentDidMount html
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $(html)[0]
        expect(args[1][0]).toEqual $('input[type="checkbox"]', html)[0]
        expect(args[2]).toEqual success: @successCallback

  describe "AssigneeDropDown", ->
    beforeEach ->
      @component = Tahi.overlays.components.AssigneeDropDown
        action: '/form/action'
        assignees: [[1, 'one'], [2, 'two']]

    describe "#render", ->
      it "generates a form for the task", ->
        form = @component.render()
        expect(form.props.action).toEqual '/form/action'

      it "generates an option for each assignee", ->
        options = @component.render().props.children[1].props.children
        optionData = options.map (o) -> { value: o.props.value, name: o.props.children }
        expect(optionData).toContain { value: 1, name: 'one' }
        expect(optionData).toContain { value: 2, name: 'two' }

      it "includes a 'Please select an assignee' option", ->
        options = @component.render().props.children[1].props.children
        optionData = options.map (o) -> { value: o.props.value, name: o.props.children }
        expect(optionData).toContain { value: null, name: 'Please select assignee' }

      context "when the task is already assigned", ->
        beforeEach -> @component.props.assigneeId = 1

        it "sets the current assigneeId", ->
          select = @component.render().props.children[1]
          expect(select.props.defaultValue).toEqual 1

      context "when the task isn't assigned", ->
        beforeEach -> @component.props.assigneeId = null

        it "does not set an assigneeId", ->
          select = @component.render().props.children[1]
          expect(select.props.defaultValue).toEqual null

    describe "#componentDidMount", ->
      it "sets up submit on change for the drop down", ->
        spyOn Tahi, 'setupSubmitOnChange'
        html = $('<form><select /></form>')[0]
        @component.componentDidMount html
        args = Tahi.setupSubmitOnChange.calls.mostRecent().args
        expect(args[0][0]).toEqual $(html)[0]
        expect(args[1][0]).toEqual $('select', html)[0]

  describe "OverlayHeader", ->
    describe "#render", ->
      it "includes the paper title which is a link to the paper", ->
        component = Tahi.overlays.components.OverlayHeader
          paperTitle: 'A title'
          paperPath: '/path/to/paper'

        link = component.render().props.children[0].props.children
        expect(link.props.href).toEqual '/path/to/paper'
        expect(link.props.children).toEqual 'A title'

      # it "includes the paper title which is a link to the paper", (done) ->
      #   component = Tahi.overlays.components.OverlayHeader
      #     paperTitle: 'A title'
      #     paperPath: '/path/to/paper'

      #   React.renderComponentToString component, (markup) ->
      #     link = $('h2 a', markup)
      #     expect(link.attr 'href').toEqual '/path/to/paper'
      #     expect(link.text()).toEqual 'A title'
      #     done()

      it "passes an on click callback to the close button", ->
        callback = jasmine.createSpy 'closeCallback'
        component = Tahi.overlays.components.OverlayHeader
          closeCallback: callback

        button  = component.render().props.children[1]
        expect(button.props.onClick).toEqual callback

  describe "OverlayFooter", ->
    describe "#componentDidMount", ->
      it "adds event listener on keyup to #handleEscKey", ->
        spyOn window, 'addEventListener'
        component = Tahi.overlays.components.OverlayFooter()
        component.componentDidMount()
        expect(window.addEventListener).toHaveBeenCalledWith 'keyup', component.handleEscKey

    describe "#componentWillUnmount", ->
      it "removes event listener on keyup to #handleEscKey", ->
        spyOn window, 'removeEventListener'
        component = Tahi.overlays.components.OverlayFooter()
        component.componentWillUnmount()
        expect(window.removeEventListener).toHaveBeenCalledWith 'keyup', component.handleEscKey

    describe "#handleEscKey", ->
      beforeEach ->
        @callback = jasmine.createSpy 'closeCallback'
        @component = Tahi.overlays.components.OverlayFooter
          closeCallback: @callback
        @event = jasmine.createSpy 'event'

      context "if the key code is 27", ->
        it "close callback is called", ->
          @event.keyCode = 27
          @component.handleEscKey @event
          expect(@callback).toHaveBeenCalledWith @event

      context "if the key code isn't 27", ->
        it "close callback is not called", ->
          @event.keyCode = 'random'
          @component.handleEscKey @event
          expect(@callback).not.toHaveBeenCalled()

    describe "#render", ->
      it "passes an on click callback to the close button", ->
        callback = jasmine.createSpy 'closeCallback'
        component = Tahi.overlays.components.OverlayFooter
          closeCallback: callback

        button  = component.render().props.children[1]
        expect(button.props.onClick).toEqual callback

      it "passes onCompletedChanged as an onSuccess callback to CompletedCheckbox", ->
        callback = jasmine.createSpy 'onCompletedChanged'
        component = Tahi.overlays.components.OverlayFooter
          onCompletedChanged: callback

        checkbox  = component.render().props.children[0].props.children[1].props.children
        expect(checkbox.props.onSuccess).toEqual callback

      it "passes assigneeId and assignees to AssigneeDropDown", ->
        component = Tahi.overlays.components.OverlayFooter
          assigneeId: 1
          assignees: [[1, 'one']]

        assigneeDropDown  = component.render().props.children[0].props.children[0].props.children
        expect(assigneeDropDown.props.assigneeId).toEqual 1
        expect(assigneeDropDown.props.assignees).toEqual [[1, 'one']]

      context "when assignees property is an empty array", ->
        it "does not render the AssigneeDropDown", ->
          component = Tahi.overlays.components.OverlayFooter
            assigneeId: null
            assignees: []

          content = component.render().props.children[0].props.children[0].props.children
          expect(content).toBeUndefined()

      context "when assignees property is undefined", ->
        it "does not render the AssigneeDropDown", ->
          component = Tahi.overlays.components.OverlayFooter
            assigneeId: null
            assignees: undefined

          content = component.render().props.children[0].props.children[0].props.children
          expect(content).toBeUndefined()

  describe "RailsFormHiddenDiv", ->
    describe "#render", ->
      it "contains a hidden field containing the specified method", ->
        component = Tahi.overlays.components.RailsFormHiddenDiv method: 'foo'
        methodField  = component.render().props.children[1]
        expect(methodField.props.value).toEqual 'foo'

      # it "contains a hidden field containing the specified method", (done) ->
      #   component = Tahi.overlays.components.RailsFormHiddenDiv method: 'foo'
      #   React.renderComponentToString component, (markup) ->
      #     field = $('input[name="_method"]', markup)
      #     expect(field.val()).toEqual 'foo'
      #     done()
