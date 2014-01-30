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
         data-card-name="some-card"><span>Foo</span></a>
      <a href="#"
         id="link2"
         data-card-name="some-card">Bar</a>
         data-paper-title="Something"
         data-paper-path="/path/to/paper"
         data-assignee-id="2"
         data-assignees='[[1,"User 1"],[2,"User 2"]]'
         data-task-path="/path/to/task"
      <div id="new-overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "binds click on all elements with data-card-name=some-card", ->
      spyOn Tahi.overlay, 'display'
      constructComponentCallback = jasmine.createSpy 'constructComponent'
      Tahi.overlay.init 'some-card', constructComponentCallback
      $('#link1').click()

      expect(Tahi.overlay.display).toHaveBeenCalledWith(
        jasmine.objectContaining(target: $('#link1')[0]),
        constructComponentCallback
      )

      Tahi.overlay.display.calls.reset()
      $('#link2').click()
      expect(Tahi.overlay.display).toHaveBeenCalledWith(
        jasmine.objectContaining(target: $('#link2')[0]),
        constructComponentCallback
      )

  describe "#display", ->
    beforeEach ->
      spyOn React, 'renderComponent'
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link1')
      @overlay = jasmine.createSpy 'someOverlay'
      @constructComponentCallback = jasmine.createSpy 'constructComponent'
      @constructComponentCallback.and.returnValue @overlay
      spyOn(Tahi.overlay, 'defaultProps').and.returnValue one: 1, two: 2

    it "prevents event propagation", ->
      Tahi.overlay.display @event, @constructComponentCallback
      expect(@event.preventDefault).toHaveBeenCalled()

    it "invokes constructComponentCallback to obtain a component", ->
      @event.target = $('#link1 span')
      Tahi.overlay.display @event, @constructComponentCallback
      expect(@constructComponentCallback).toHaveBeenCalled()
      args = @constructComponentCallback.calls.mostRecent().args
      expect(args[0][0]).toEqual document.getElementById('link1')
      expect(args[1]).toEqual one: 1, two: 2

    it "renders constructed component, mounting it on #new-overlay", ->
      Tahi.overlay.display @event, @constructComponentCallback
      expect(React.renderComponent).toHaveBeenCalledWith(@overlay, $('#new-overlay')[0], Tahi.initChosen)

    it "displays the overlay", ->
      Tahi.overlay.display @event, @constructComponentCallback
      expect($('#new-overlay')).toBeVisible()

    it "adds the noscroll class to the body", ->
      spyOn $.fn, 'addClass'
      Tahi.overlay.display @event, @constructComponentCallback
      expect($.fn.addClass.calls.mostRecent().object.selector).toEqual 'html'
      expect($.fn.addClass).toHaveBeenCalledWith('noscroll')

  describe "#hide", ->
    beforeEach ->
      $('#new-overlay').show()
      @event = jasmine.createSpyObj 'event', ['preventDefault']

    it "prevents default on the event", ->
      Tahi.overlay.hide(@event)
      expect(@event.preventDefault).toHaveBeenCalled()

    it "hides the overlay", ->
      Tahi.overlay.hide(@event)
      expect($('#new-overlay')).toBeHidden()

    it "removes the noscroll class from the html", ->
      spyOn $.fn, 'removeClass'
      Tahi.overlay.hide(@event)
      expect($.fn.removeClass.calls.mostRecent().object.selector).toEqual 'html'
      expect($.fn.removeClass).toHaveBeenCalledWith('noscroll')

    it "unmounts the component", ->
      spyOn React, 'unmountComponentAtNode'
      Tahi.overlay.hide(@event)
      expect(React.unmountComponentAtNode).toHaveBeenCalledWith document.getElementById('new-overlay')

  describe "#defaultProps", ->
    beforeEach ->
      @event = jasmine.createSpyObj 'event', ['preventDefault']
      @event.target = document.getElementById('link1')

    it "includes default properties pulled from the event target", ->
      props = Tahi.overlay.defaultProps $(@event.target)
      expect(props.paperTitle).toEqual 'Something'
      expect(props.paperPath).toEqual '/path/to/paper'
      expect(props.taskPath).toEqual '/path/to/task'
      expect(props.assignees).toEqual [[1, 'User 1'], [2, 'User 2']]
      expect(props.assigneeId).toEqual 2

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
      beforeEach ->
        spyOn Turbolinks, 'visit'
        @callback = Tahi.overlay.defaultProps($(@event.target)).onOverlayClosed

      it "uses Turbolinks to reload the page", ->
        @callback null, completed: true
        expect(Turbolinks.visit).toHaveBeenCalledWith window.location

      context "when data-refresh-on-close is false", ->
        it "does not reload the page", ->
          $('#link1, #link2').data('refreshOnClose', false)
          @callback null, completed: true
          expect(Turbolinks.visit).not.toHaveBeenCalled()

    describe "taskCompleted", ->
      context "when the event target does not have the completed class", ->
        it "returns taskCompleted: false", ->
          $('#link1, #link2').removeClass 'completed'
          props = Tahi.overlay.defaultProps $(@event.target)
          expect(props.taskCompleted).toEqual false

      context "when the event target has the completed class", ->
        it "returns taskCompleted: true", ->
          $('#link1, #link2').addClass 'completed'
          props = Tahi.overlay.defaultProps $(@event.target)
          expect(props.taskCompleted).toEqual true
