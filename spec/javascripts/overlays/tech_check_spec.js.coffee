beforeEach ->
  $('#jasmine_content').empty()

describe "Tech Check Card", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#"
         id="link1"
         data-card-name="tech-check">Foo</a>
      <a href="#"
         id="link2"
         data-card-name="tech-check">Bar</a>
      <div id="new-overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "calls Tahi.overlay.init", ->
      spyOn Tahi.overlay, 'init'
      Tahi.overlays.techCheck.init()
      expect(Tahi.overlay.init).toHaveBeenCalledWith 'tech-check', Tahi.overlays.techCheck.createComponent

  describe "#createComponent", ->
    it "instantiates a TechCheckOverlay component", ->
      spyOn Tahi.overlays.techCheck.components, 'TechCheckOverlay'
      Tahi.overlays.techCheck.createComponent $('#link1'), one: 1, two: 2
      expect(Tahi.overlays.techCheck.components.TechCheckOverlay).toHaveBeenCalledWith(
        jasmine.objectContaining
          one: 1
          two: 2
      )

  describe "TechCheckOverlay component", ->
    describe "#render", ->
      beforeEach ->
        @onOverlayClosedCallback = jasmine.createSpy 'onOverlayClosed'
        @component = Tahi.overlays.techCheck.components.TechCheckOverlay
          paperTitle: 'Something'
          paperPath: '/path/to/paper'
          onOverlayClosed: @onOverlayClosedCallback

      it "renders an Overlay component wrapping our content", ->
        overlay = @component.render()
        Overlay = Tahi.overlays.components.Overlay
        expect(overlay.constructor).toEqual Overlay.componentConstructor
        expect(overlay.props.onOverlayClosed).toEqual @onOverlayClosedCallback
