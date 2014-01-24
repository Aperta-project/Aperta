beforeEach ->
  $('#jasmine_content').empty()

describe "Upload Manuscript Card", ->
  beforeEach ->
    $('#jasmine_content').html """
      <a href="#"
         id="link1"
         data-card-name="upload-manuscript">Foo</a>
      <a href="#"
         id="link2"
         data-card-name="upload-manuscript">Bar</a>
      <div id="new-overlay" style="display: none;"></div>
    """

  describe "#init", ->
    it "calls Tahi.overlay.init", ->
      spyOn Tahi.overlay, 'init'
      Tahi.overlays.uploadManuscript.init()
      expect(Tahi.overlay.init).toHaveBeenCalledWith 'upload-manuscript', Tahi.overlays.uploadManuscript.createComponent

  describe "#createComponent", ->
    it "instantiates a UploadManuscriptOverlay component", ->
      spyOn Tahi.overlays.uploadManuscript.components, 'UploadManuscriptOverlay'
      Tahi.overlays.uploadManuscript.createComponent $('#link1'), one: 1, two: 2
      expect(Tahi.overlays.uploadManuscript.components.UploadManuscriptOverlay).toHaveBeenCalledWith(
        jasmine.objectContaining
          one: 1
          two: 2
      )

  describe "UploadManuscriptOverlay component", ->
    describe "#render", ->
      beforeEach ->
        @onOverlayClosedCallback = jasmine.createSpy 'onOverlayClosed'
        @component = Tahi.overlays.uploadManuscript.components.UploadManuscriptOverlay
          paperTitle: 'Something'
          paperPath: '/path/to/paper'
          onOverlayClosed: @onOverlayClosedCallback

      it "renders an Overlay component wrapping our content", ->
        overlay = @component.render()
        Overlay = Tahi.overlays.components.Overlay
        expect(overlay.constructor).toEqual Overlay.componentConstructor
        expect(overlay.props.onOverlayClosed).toEqual @onOverlayClosedCallback

