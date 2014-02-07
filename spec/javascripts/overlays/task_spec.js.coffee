beforeEach ->
  $('#jasmine_content').empty()

describe "Task Card", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#"
         id="link1"
         data-task-body="Too many muscles!"
         data-card-name="task">Foo</a>
      <a href="#"
         id="link2"
         data-task-body="Too many muscles!"
         data-card-name="task">Bar</a>
      <div id="overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "calls Tahi.overlay.init", ->
      spyOn Tahi.overlay, 'init'
      Tahi.overlays.task.init()
      expect(Tahi.overlay.init).toHaveBeenCalledWith 'task'

  describe "#createComponent", ->
    it "instantiates a TaskOverlay component", ->
      spyOn Tahi.overlays.task.components, 'TaskOverlay'
      Tahi.overlays.task.createComponent $('#link1'), one: 1, two: 2
      expect(Tahi.overlays.task.components.TaskOverlay).toHaveBeenCalledWith(
        jasmine.objectContaining
          one: 1
          two: 2
          taskBody: 'Too many muscles!'
      )

  describe "TaskOverlay component", ->
    describe "#render", ->
      beforeEach ->
        @onOverlayClosedCallback = jasmine.createSpy 'onOverlayClosed'
        @component = Tahi.overlays.task.components.TaskOverlay
          paperTitle: 'Something'
          paperPath: '/path/to/paper'
          onOverlayClosed: @onOverlayClosedCallback
          taskBody: 'Too many muscles!'

      it "renders an Overlay component wrapping our content", ->
        overlay = @component.render()
        Overlay = Tahi.overlays.components.Overlay
        expect(overlay.constructor).toEqual Overlay.componentConstructor
        expect(overlay.props.onOverlayClosed).toEqual @onOverlayClosedCallback

      it "includes the task body", ->
        overlay = @component.render()
        expect(overlay.props.children.props.children[1].props.children).toEqual 'Too many muscles!'
