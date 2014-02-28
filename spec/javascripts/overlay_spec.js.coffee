describe "Tahi.overlay", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="/path/to/task/11"
         id="link1"
         data-task-id="11"
         data-card-name="some-card"><span>Foo</span></a>
      <a href="/path/to/task/12"
         id="link2"
         data-task-id="12"
         data-card-name="some-other-card">Bar</a>
      <div id="overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "binds click on all elements with data-card-name=some-card", ->
      spyOn Tahi.overlay, 'display'
      Tahi.overlay.init()
      $('#link1').click()
      $('#link2').click()

      expect(Tahi.overlay.display).toHaveBeenCalledWith(
        jasmine.objectContaining(target: $('#link1')[0]),
        'some-card'
      )

      expect(Tahi.overlay.display).toHaveBeenCalledWith(
        jasmine.objectContaining(target: $('#link2')[0]),
        'some-other-card'
      )

  describe "#renderCard", ->
    beforeEach ->
      spyOn React, 'renderComponent'
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link1')
      @overlay = jasmine.createSpy 'someOverlay'
      spyOn(Tahi.overlays.components, 'Overlay').and.returnValue @overlay
      Tahi.overlays.someCard =
        Overlay: jasmine.createSpy 'someCard overlay'
      spyOn(Tahi.overlay, 'defaultProps').and.returnValue one: 1, two: 2

    it "creates a Overlay component", ->
      Tahi.overlay.renderCard 'some-card', @event.target
      expect(Tahi.overlays.components.Overlay).toHaveBeenCalledWith
        one: 1
        two: 2
        componentToRender: Tahi.overlays.someCard.Overlay

    it "retrieves properties from the target", ->
      Tahi.overlay.renderCard 'some-card', @event.target
      expect(Tahi.overlay.defaultProps).toHaveBeenCalledWith @event.target

    it "renders constructed component, mounting it on #overlay", ->
      Tahi.overlay.renderCard 'some-card', @event.target
      expect(React.renderComponent).toHaveBeenCalledWith(@overlay, $('#overlay')[0])

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
        taskHref: '/path/to/task/11'
      expect(history.pushState).toHaveBeenCalledWith state, null, "/path/to/task/11"

  describe "#popstateOverlay", ->
    beforeEach ->
      @historyObj = jasmine.createSpy()
      spyOn(Tahi.utils, 'windowHistory').and.returnValue(@historyObj)
      spyOn(Tahi.overlay, 'renderCard')

    it "renders the component if the history state and cardName are present", ->
      @historyObj.state =
        cardName: 'Hello'
        taskHref: '/path/to/task/11'

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

      context "when turbolinks state is not provided", ->
        it "doesn't invoke history.pushState", ->
          @event.type = 'notPopstate'
          Tahi.overlay.hide(@event)
          expect(history.pushState).not.toHaveBeenCalled()

  describe "#defaultProps", ->
    beforeEach ->
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link1')

    it "includes default properties pulled from the event target", ->
      props = Tahi.overlay.defaultProps($(@event.target))
      expect(props.taskPath).toEqual '/path/to/task/11'

    describe "onCompletedChanged callback", ->
      beforeEach ->
        @callback = Tahi.overlay.defaultProps($(@event.target)).onCompletedChanged

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
        Tahi.overlay.defaultProps($('#link1')).onOverlayClosed('foo')
        expect(Tahi.overlay.hide).toHaveBeenCalledWith('foo', window.history.state)
