describe "Tahi.overlay", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#"
         id="link1"
         data-paper-title="Something"
         data-paper-path="/path/to/paper"
         data-task-path="/path/to/task"
         data-assignee-id="2"
         data-assignees='[[1,"User 1"],[2,"User 2"]]'
         data-card-name="some-card"
         data-task-id="12"><span>Foo</span></a>
      <a href="#"
         id="link2"
         data-paper-title="Something"
         data-paper-path="/path/to/paper"
         data-assignee-id="2"
         data-assignees='[[1,"User 1"],[2,"User 2"]]'
         data-task-path="/path/to/task"
         data-task-id="12"
         data-card-name="some-card">Bar</a>
      <div id="overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "binds click on all elements with data-card-name=some-card", ->
      spyOn Tahi.overlay, 'display'
      Tahi.overlay.init 'some-card'
      $('#link1').click()

      expect(Tahi.overlay.display).toHaveBeenCalledWith(
        jasmine.objectContaining(target: $('#link1')[0]),
        'some-card'
      )

      Tahi.overlay.display.calls.reset()
      $('#link2').click()
      expect(Tahi.overlay.display).toHaveBeenCalledWith(
        jasmine.objectContaining(target: $('#link2')[0]),
        'some-card'
      )

  describe "#renderCard", ->
    beforeEach ->
      spyOn(history, 'pushState')
      spyOn React, 'renderComponent'
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link1')
      @overlay = jasmine.createSpy 'someOverlay'
      Tahi.overlays.someCard = jasmine.createSpyObj 'someCard overlay', ['createComponent']
      Tahi.overlays.someCard.createComponent.and.returnValue @overlay
      spyOn(Tahi.overlay, 'defaultProps').and.returnValue one: 1, two: 2

    it "creates a someCard component", ->
      Tahi.overlay.renderCard 'some-card', @event.target
      expect(Tahi.overlays.someCard.createComponent).toHaveBeenCalledWith @event.target, one: 1, two: 2

    it "retrieves properties from the target", ->
      Tahi.overlay.renderCard 'some-card', @event.target
      expect(Tahi.overlay.defaultProps).toHaveBeenCalledWith @event.target

    it "renders constructed component, mounting it on #overlay", ->
      Tahi.overlay.renderCard 'some-card', @event.target
      expect(React.renderComponent).toHaveBeenCalledWith(@overlay, $('#overlay')[0], Tahi.initChosen)

    it "displays the overlay", ->
      Tahi.overlay.renderCard 'some-card', @event.target
      expect($('#overlay')).toBeVisible()

    it "adds the noscroll class to the body", ->
      spyOn $.fn, 'addClass'
      Tahi.overlay.renderCard 'some-card', @event.target
      expect($.fn.addClass.calls.mostRecent().object.selector).toEqual 'html'
      expect($.fn.addClass).toHaveBeenCalledWith('noscroll')

  describe "#display", ->
    beforeEach ->
      spyOn(history, 'pushState')
      spyOn React, 'renderComponent'
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link1')
      @overlay = jasmine.createSpy 'someOverlay'
      spyOn(Tahi.overlay, 'defaultProps').and.returnValue one: 1, two: 2, overlayProps: { paperPath: 'path/to/paper' }
      spyOn(Tahi.overlay, 'renderCard')

    it "prevents event propagation", ->
      Tahi.overlay.display @event, 'some-card'
      expect(@event.preventDefault).toHaveBeenCalled()

    it "calls renderCard with cardName and target element", ->
      @event.target = $('#link1 span')
      Tahi.overlay.display @event, 'some-card'
      expect(Tahi.overlay.renderCard).toHaveBeenCalled()
      args = Tahi.overlay.renderCard.calls.mostRecent().args
      expect(args[0]).toEqual 'some-card'
      expect(args[1][0]).toEqual $('#link1')[0]

    it "calls history.pushState with the currentState and tasks URL", ->
      Tahi.overlay.display @event, 'some-card'
      state =
        cardName: 'some-card'
        cardId: 12
      expect(history.pushState).toHaveBeenCalledWith state, null, "path/to/paper/tasks/12"

  describe "#popstateOverlay", ->
    beforeEach ->
      @historyObj = jasmine.createSpy()
      spyOn(Tahi.utils, 'windowHistory').and.returnValue(@historyObj)
      spyOn(Tahi.overlay, 'renderCard')

    it "renders the component if the history state and cardName are present", ->
      @historyObj.state =
        cardName: 'Hello'
        cardId: 12

      Tahi.overlay.popstateOverlay()
      expect(Tahi.overlay.renderCard).toHaveBeenCalled()
      args = Tahi.overlay.renderCard.calls.mostRecent().args
      expect(args[0]).toEqual 'Hello'
      expect(args[1][0]).toEqual $('#link1')[0]

    context "if the history doesn't have a state", ->
      it "doesn't call renderCard", ->
        Tahi.overlay.popstateOverlay()
        expect(Tahi.overlay.renderCard).not.toHaveBeenCalled()

    context "if the history state doesn't have a cardName", ->
      it "doesn't call renderCard", ->
        @historyObj.state = {}
        Tahi.overlay.popstateOverlay()
        expect(Tahi.overlay.renderCard).not.toHaveBeenCalled()

  describe "#hide", ->
    beforeEach ->
      $('#overlay').show()
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @turbolinksState = {}
      @turbolinksState.url = 'http://random/'
      spyOn history, 'pushState'

    it "prevents default on the event", ->
      Tahi.overlay.hide(@event, @turbolinksState)
      expect(@event.preventDefault).toHaveBeenCalled()

    it "hides the overlay", ->
      Tahi.overlay.hide(@event, @turbolinksState)
      expect($('#overlay')).toBeHidden()

    it "removes the noscroll class from the html", ->
      spyOn $.fn, 'removeClass'
      Tahi.overlay.hide(@event, @turbolinksState)
      expect($.fn.removeClass.calls.mostRecent().object.selector).toEqual 'html'
      expect($.fn.removeClass).toHaveBeenCalledWith('noscroll')

    it "unmounts the component", ->
      spyOn React, 'unmountComponentAtNode'
      Tahi.overlay.hide(@event, @turbolinksState)
      expect(React.unmountComponentAtNode).toHaveBeenCalledWith document.getElementById('overlay')

    context "if event type is not popstate", ->
      it "calls history.pushState with currentUrl", ->
        @event.type = 'notPopstate'
        Tahi.overlay.hide(@event, @turbolinksState)
        expect(history.pushState).toHaveBeenCalled()


  describe "#defaultProps", ->
    beforeEach ->
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link1')

    it "includes default properties pulled from the event target", ->
      props = Tahi.overlay.defaultProps($(@event.target)).overlayProps
      expect(props.paperTitle).toEqual 'Something'
      expect(props.paperPath).toEqual '/path/to/paper'
      expect(props.taskPath).toEqual '/path/to/task'
      expect(props.assignees).toEqual [[1, 'User 1'], [2, 'User 2']]
      expect(props.assigneeId).toEqual 2

    describe "onCompletedChanged callback", ->
      beforeEach ->
        @callback = Tahi.overlay.defaultProps($(@event.target)).overlayProps.onCompletedChanged

      context "when data.completed is true", ->
        it "adds the 'completed' class to all links", ->
          $('#link1, #link2').removeClass 'completed'
          expect($('#link1')).not.toHaveClass 'completed'
          @callback null, completed: true
          expect($('#link1')).toHaveClass 'completed'

      context "when data.completed is false", ->
        it "clears the 'completed' class from all links", ->
          $('#link1, #link2').addClass 'completed'
          expect($('#link1')).toHaveClass 'completed'
          @callback null, completed: false
          expect($('#link1')).not.toHaveClass 'completed'

    describe "onOverlayClosed callback", ->
      it "it calls Tahi.overlay.hide", ->
        spyOn(Tahi.overlay, 'hide')
        Tahi.overlay.defaultProps($('#link1')).overlayProps.onOverlayClosed('foo')
        expect(Tahi.overlay.hide).toHaveBeenCalledWith('foo', window.history.state)

    describe "taskCompleted", ->
      context "when the event target does not have the completed class", ->
        it "returns taskCompleted: false", ->
          $('#link1, #link2').removeClass 'completed'
          props = Tahi.overlay.defaultProps($(@event.target)).overlayProps
          expect(props.taskCompleted).toEqual false

      context "when the event target has the completed class", ->
        it "returns taskCompleted: true", ->
          $('#link1, #link2').addClass 'completed'
          props = Tahi.overlay.defaultProps($(@event.target)).overlayProps
          expect(props.taskCompleted).toEqual true
