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
      <div id="overlay" style="display: none;"></div>
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

      it "sets up a fileuploadadd handler", ->
        @component.componentDidMount(@html)
        expect(@fakeUploader.on).toHaveBeenCalledWith 'fileuploadadd', @component.fileUploadAdd

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

        @event = jasmine.createSpyObj 'event', ['target', 'preventDefault']
        @data = jasmine.createSpy 'data'
        @previewElement = $('<div id="file-preview" />')[0]
        @data.files = [
          { preview: @previewElement, name: 'real-yeti.jpg' }
        ]

      describe "#fileUploadAdd", ->
        beforeEach ->
          @component.fileUploadProcessAlways @event, @data
          expect(@component.setState).toHaveBeenCalledWith
            uploadProgress: 0
          @component.state ||= {}
          @data.submit = jasmine.createSpy 'data#submit'
          @data.originalFiles = [{ name: 'real-yeti.docx' }]

        it "clears any errors", ->
          @component.fileUploadAdd @event, @data
          expect(@component.setState).toHaveBeenCalledWith error: null

        it "submits the data", ->
          @component.fileUploadAdd @event, @data
          expect(@data.submit).toHaveBeenCalled()

        it "does not prevent default on the event", ->
          @component.fileUploadAdd @event, @data
          expect(@event.preventDefault).not.toHaveBeenCalled()

        context "when the file is not an accepted format", ->
          beforeEach ->
            @data.originalFiles = [{ name: 'real-yeti.jpg' }]

          it "sets errors", ->
            @component.fileUploadAdd @event, @data
            errorMessage =  "Sorry! 'real-yeti.jpg' is not of an accepted file type"
            expect(@component.setState).toHaveBeenCalledWith error: errorMessage

          it "prevents default on the event", ->
            @component.fileUploadAdd @event, @data
            expect(@event.preventDefault).toHaveBeenCalled()

          it "does not submit the data", ->
            @component.fileUploadAdd @event, @data
            expect(@data.submit).not.toHaveBeenCalled()

      describe "#fileUploadProcessAlways", ->
        it "updates the upload state", ->
          @component.fileUploadProcessAlways @event, @data
          expect(@component.setState).toHaveBeenCalledWith
            uploadProgress: 0

        context "when there are errors", ->
          it "does not update the upload state", ->
            @component.state = error: 'foo'
            @component.fileUploadProcessAlways @event, @data
            expect(@component.setState).not.toHaveBeenCalled()

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
