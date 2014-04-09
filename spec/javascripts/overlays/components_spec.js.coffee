describe "Tahi overlay components", ->
  describe "Overlay", ->
    beforeEach ->
      @onCompletedChangedCallback = jasmine.createSpy 'onCompletedChanged'
      @onOverlayClosedCallback = jasmine.createSpy 'onOverlayClosed'
      @mainComponent = jasmine.createSpy 'fakeComponent'
      @component = Tahi.overlays.components.Overlay
        taskPath: '/path/to/task'
        componentToRender: @mainComponent
        onOverlayClosed: @onOverlayClosedCallback
        onCompletedChanged: @onCompletedChangedCallback

    describe "#render", ->
      it "renders an overlay header", ->
        @component.state =
          jQuery.extend @component.props,
            paperTitle: "A working title",
            paperPath: "/path/to/paper"
        header = @component.render().props.children[0]
        OverlayHeader = Tahi.overlays.components.OverlayHeader
        expect(header.constructor).toEqual OverlayHeader.componentConstructor
        expect(header.props.paperTitle).toEqual 'A working title'
        expect(header.props.paperPath).toEqual '/path/to/paper'
        expect(header.props.closeCallback).toEqual @onOverlayClosedCallback

      it "renders an overlay footer, passing it an onCompletedChanged callback", ->
        @component.state =
          jQuery.extend @component.props,
            paperPath: "/path/to/paper",
            taskCompleted: false,

        footer = @component.render().props.children[2]
        OverlayFooter = Tahi.overlays.components.OverlayFooter
        expect(footer.constructor).toEqual OverlayFooter.componentConstructor
        expect(footer.props.checkboxFormAction).toEqual '/path/to/task.json'
        expect(footer.props.taskCompleted).toEqual false
        expect(footer.props.onCompletedChanged).toEqual @onCompletedChangedCallback
        expect(footer.props.closeCallback).toEqual @onOverlayClosedCallback

      it "renders the main content between the header and footer", ->
        main = React.DOM.main()
        @mainComponent.and.returnValue main
        @component.state =
          jQuery.extend @component.props,
            one: 1
            two: 2
        mainContent = @component.render().props.children[1]
        expect(@mainComponent).toHaveBeenCalledWith @component.state
        expect(mainContent).toEqual main

    describe "#componentDidMount", ->
      it "sends an Ajax request to grab data attributes", ->
        spyOn($, 'ajax')
        spyOn @component, 'setState'
        @component.componentDidMount()
        expect($.ajax).toHaveBeenCalledWith jasmine.objectContaining
          url: '/path/to/task'
          dataType: 'json'
          success: @component.updateState

    describe "#updateState", ->
      it "sets data as the state of the component", ->
        spyOn @component, 'setState'
        @component.updateState {one: 1, two: 2}
        expect(@component.setState).toHaveBeenCalledWith one: 1, two: 2, loading: false

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
        taskCompleted: false

    describe "#render", ->
      beforeEach ->
        @component.state = taskCompleted: false

      it "generates a form for the task", ->
        form = @component.render()
        expect(form.props.action).toEqual '/form/action'

      context "when the task has been completed", ->
        beforeEach -> @component.state.taskCompleted = true

        it "checks the checkbox", ->
          checkbox = @component.render().props.children.props.children[1]
          expect(checkbox.props.checked).toEqual true

      context "when the task has not been completed", ->
        beforeEach -> @component.state.taskCompleted = false

        it "does not check the checkbox", ->
          checkbox = @component.render().props.children.props.children[1]
          expect(checkbox.props.checked).toEqual false

  describe "AssigneeDropDown", ->
    beforeEach ->
      @component = Tahi.overlays.components.AssigneeDropDown
        action: '/form/action'
        assignees: [{id: 1, full_name: 'one'}, {id: 2, full_name: 'two'}]

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
