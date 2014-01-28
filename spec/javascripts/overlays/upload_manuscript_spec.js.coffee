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
        @component.state = uploadProgress: null

      it "renders an Overlay component wrapping our content", ->
        overlay = @component.render()
        Overlay = Tahi.overlays.components.Overlay
        expect(overlay.constructor).toEqual Overlay.componentConstructor
        expect(overlay.props.onOverlayClosed).toEqual @onOverlayClosedCallback

    describe "#componentDidMount", ->
      beforeEach ->
        @fakeUploader = jasmine.createSpyObj 'uploader', ['on']
        spyOn($.fn, 'fileupload').and.returnValue @fakeUploader
        @html = $("""
          <div>
            <input id='jquery-file-attachment' type='file' class='js-jquery-fileupload' />
            <input id='file-attachment' type='file' />
          </div>
        """)[0]
        @component = Tahi.overlays.uploadManuscript.components.UploadManuscriptOverlay()

      it "initializes jQuery filepicker", ->
        @component.componentDidMount(@html)
        expect($.fn.fileupload).toHaveBeenCalled()
        call = $.fn.fileupload.calls.mostRecent()
        expect(call.object).toEqual $('#jquery-file-attachment', @html)

      it "sets up a fileuploadprocessalways handler", ->
        @component.componentDidMount(@html)
        expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploadprocessalways', @component.fileUploadProcessAlways

      it "sets up a fileuploadprogress handler", ->
        @component.componentDidMount(@html)
        expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploadprogress', @component.fileUploadProgress

    describe "jQuery File Upload callbacks", ->
      beforeEach ->
        @component = Tahi.overlays.uploadManuscript.components.UploadManuscriptOverlay()
        spyOn @component, 'setState'

        @event = jasmine.createSpyObj 'event', ['target']
        @data = jasmine.createSpy 'data'
        @previewElement = $('<div id="file-preview" />')[0]
        @data.files = [
          { preview: @previewElement, name: 'real-yeti.jpg' }
        ]

      describe "#fileUploadProcessAlways", ->
        it "updates the upload state", ->
          @component.fileUploadProcessAlways @event, @data
          expect(@component.setState).toHaveBeenCalledWith
            uploadProgress: 0

      describe "#fileUploadProgress", ->
        it "updates state with the current progress", ->
          @component.state =
            uploadProgress: 0
          @data.loaded = 124.0
          @data.total = 620.0
          # 124.0 * 100 / 620.0 = 20
          @component.fileUploadProgress @event, @data
          expect(@component.setState).toHaveBeenCalledWith
            uploadProgress: 20
